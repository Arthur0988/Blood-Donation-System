const express = require('express');
const sql = require('msnodesqlv8');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Universal connection strings for any Windows laptop running SQL Server Express
const CANDIDATE_CONN_STRINGS = [
  process.env.DB_CONN_STRING,
  'Driver={ODBC Driver 17 for SQL Server};Server=localhost\\SQLEXPRESS;Database=BloodDonationSystem;Trusted_Connection=yes;',
  'Driver={ODBC Driver 18 for SQL Server};Server=localhost\\SQLEXPRESS;Database=BloodDonationSystem;Trusted_Connection=yes;TrustServerCertificate=yes;',
  'Driver={ODBC Driver 17 for SQL Server};Server=localhost;Database=BloodDonationSystem;Trusted_Connection=yes;',
  'Driver={ODBC Driver 18 for SQL Server};Server=localhost;Database=BloodDonationSystem;Trusted_Connection=yes;TrustServerCertificate=yes;',
  'Driver={SQL Server};Server=localhost\\SQLEXPRESS;Database=BloodDonationSystem;Trusted_Connection=yes;'
].filter(Boolean);

let activeConnString = CANDIDATE_CONN_STRINGS[0];

function queryAsync(queryText, params = []) {
  return new Promise((resolve, reject) => {
    sql.query(activeConnString, queryText, params, (err, rows) => {
      if (err) return reject(err);
      resolve(rows || []);
    });
  });
}

async function detectWorkingSqlConnection() {
  for (const connStr of CANDIDATE_CONN_STRINGS) {
    try {
      await new Promise((resolve, reject) => {
        sql.query(connStr, 'SELECT 1 AS ok', (err) => (err ? reject(err) : resolve()));
      });
      activeConnString = connStr;
      console.log('Connected to SQL Server using:', connStr);
      return true;
    } catch (_) {
      // Try next driver/instance
    }
  }
  console.error('WARNING: Could not connect to SQL Server Express on localhost.');
  return false;
}

// 1. Login Endpoint
app.post('/api/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    const rows = await queryAsync(
      `SELECT u.UserID, u.Username, s.StaffID, s.Name, s.Role
       FROM SYSTEM_USERS u
       INNER JOIN MEDICAL_STAFF s ON u.StaffID = s.StaffID
       WHERE u.Username = ? AND u.Password_Hash = ?`,
      [username, password]
    );
    if (!rows.length) {
      return res.status(401).json({ success: false, message: 'Invalid username or password.' });
    }
    res.json({ success: true, user: rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// 2. Fetch All 6 Core Tables
app.get('/api/all', async (req, res) => {
  try {
    const [donors, staff, screening, bags, components, requests] = await Promise.all([
      queryAsync('SELECT * FROM DONOR ORDER BY DonorID DESC'),
      queryAsync('SELECT * FROM MEDICAL_STAFF ORDER BY StaffID ASC'),
      queryAsync('SELECT * FROM SCREENING ORDER BY ScreeningID DESC'),
      queryAsync('SELECT * FROM BLOOD_BAGS ORDER BY Bag_Serial_Number DESC'),
      queryAsync('SELECT * FROM BLOOD_COMPONENTS ORDER BY ComponentID DESC'),
      queryAsync('SELECT * FROM BLOOD_REQUESTS ORDER BY RequestID DESC')
    ]);

    res.json({
      donors,
      staff,
      screening,
      screenings: screening,
      bags,
      components,
      requests
    });
  } catch (err) {
    console.error('GET /api/all Error:', err);
    res.status(500).json({ error: err.message });
  }
});

// 3. Create Donor
app.post('/api/donors', async (req, res) => {
  try {
    const d = req.body;
    await queryAsync(
      `INSERT INTO DONOR (Donation_Form, First_Name, Last_Name, Middle_Name, Birth_Date, Age, Civil_Status, Sex, Weight_KG, Blood_Type, Donor_Status, Last_Donation_Date)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        d.Donation_Form,
        d.First_Name,
        d.Last_Name,
        d.Middle_Name || null,
        d.Birth_Date,
        Number(d.Age),
        d.Civil_Status,
        d.Sex,
        Number(d.Weight_KG),
        d.Blood_Type,
        d.Donor_Status || 'Eligible',
        d.Last_Donation_Date || null
      ]
    );
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 4. Create Medical Screening
app.post('/api/screening', async (req, res) => {
  try {
    const s = req.body;
    await queryAsync(
      `INSERT INTO SCREENING (DonorID, StaffID, Screening_Date, Systolic_BP, Diastolic_BP, Pulse_Rate, Has_Recent_Tattoos, Screening_Result, Interview_Sheet, Medical_History)
       VALUES (?, ?, GETDATE(), ?, ?, ?, ?, ?, ?, ?)`,
      [
        Number(s.DonorID),
        Number(s.StaffID),
        Number(s.Systolic_BP),
        Number(s.Diastolic_BP),
        Number(s.Pulse_Rate),
        s.Has_Recent_Tattoos ? 1 : 0,
        s.Screening_Result,
        s.Interview_Sheet || 'Complete and verified',
        s.Medical_History || 'None'
      ]
    );
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 5. Create Blood Bag
app.post('/api/bags', async (req, res) => {
  try {
    const b = req.body;
    await queryAsync(
      `INSERT INTO BLOOD_BAGS (Bag_Serial_Number, DonorID, Collection_Date, TTI_Status, Bag_Status)
       VALUES (?, ?, ?, ?, ?)`,
      [
        b.Bag_Serial_Number,
        Number(b.DonorID),
        b.Collection_Date,
        b.TTI_Status || 'Non-Reactive',
        b.Bag_Status || 'Processed'
      ]
    );
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 6. Create Blood Component
app.post('/api/components', async (req, res) => {
  try {
    const c = req.body;
    await queryAsync(
      `INSERT INTO BLOOD_COMPONENTS (Bag_Serial_Number, Component_Type, Storage_Location, Expiration_Date, Availability_Status, RequestID)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [
        c.Bag_Serial_Number,
        c.Component_Type,
        c.Storage_Location,
        c.Expiration_Date,
        c.Availability_Status || 'Available',
        c.RequestID ? Number(c.RequestID) : null
      ]
    );
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 7. Create Blood Request
app.post('/api/requests', async (req, res) => {
  try {
    const r = req.body;
    const isSamaritan = r.Is_Blood_Samaritan ? 1 : 0;
    const fee = isSamaritan ? 0.0 : Number(r.Processing_Fee ?? 1800.0);
    await queryAsync(
      `INSERT INTO BLOOD_REQUESTS (Patient_Name, Hospital_Name, Required_Blood_Type, Quantity_Requested, Is_Blood_Samaritan, Processing_Fee, Request_Status)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        r.Patient_Name,
        r.Hospital_Name,
        r.Required_Blood_Type,
        Number(r.Quantity_Requested),
        isSamaritan,
        fee,
        r.Request_Status || 'Pending'
      ]
    );
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 8. Fulfill Blood Request
app.put('/api/requests/:id/fulfill', async (req, res) => {
  try {
    await queryAsync(
      `UPDATE BLOOD_REQUESTS SET Request_Status = 'Fulfilled' WHERE RequestID = ?`,
      [Number(req.params.id)]
    );
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 9. Create Medical Staff
app.post('/api/staff', async (req, res) => {
  try {
    const { Name, Role } = req.body;
    await queryAsync(`INSERT INTO MEDICAL_STAFF (Name, Role) VALUES (?, ?)`, [Name, Role]);
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

detectWorkingSqlConnection().then(() => {
  app.listen(PORT, () => {
    console.log(`Philippine Red Cross Blood System running at http://localhost:${PORT}`);
  });
});