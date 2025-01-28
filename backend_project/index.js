const express = require('express');
const mysql = require('mysql2');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const bodyParser = require('body-parser');
const cors = require('cors');
const nodemailer = require('nodemailer'); // Import nodemailer

const app = express();
const port = 3000;

// Middleware
app.use(cors()); // Allow Cross-Origin requests from Flutter
app.use(bodyParser.json()); // Parse JSON request body

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    // Set the destination to save files
    const uploadDir = path.join(__dirname, 'uploads');
    
    // Create directory if it doesn't exist
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir);
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    // Keep the original file name
    cb(null, file.originalname);
  },
}); // Use memory storage to store files in memory
const upload = multer({ storage });


// MySQL database connection
const db = mysql.createConnection({
  host: 'localhost',   // MySQL host
  user: 'root',        // MySQL username
  password: 'Naresh@2025', // MySQL password
  database: 'edubond'  // Database name
});

// Connect to the MySQL database
db.connect((err) => {
  if (err) {
    throw err;
  }
  console.log('MySQL Connected...');
});

// Create a transporter for nodemailer

const transporter = nodemailer.createTransport({
  // host: 'smtp.gmail.com',
  // port: 587, // Use port 465 for SSL, or 587 for TLS
  // secure: false, // Set to true if using port 465
  service: 'gmail', // Use your email provider (e.g., Gmail)
  auth: {
    user: 'edubond2022@gmail.com', // Your email
    pass: 'zefd gams vzap pkyd',
    //pass: 'erqp annk fije zwtc', // Your email password or app password
  },
});

// A simple route for testing
app.get('/', (req, res) => {
  res.send('Hello from the backend!');
});

// Signup route
app.post('/signup', (req, res) => {
  const { username, email, password } = req.body;

  // Insert user into database
  const sql = 'INSERT INTO users (username, email, password) VALUES (?, ?, ?)';
  db.query(sql, [username, email, password], (err, result) => {
    if (err) throw err;
    res.send({ message: 'User created successfully', userId: result.insertId });
  });
});
let otpStorage = {};
// OTP generation and sending route
app.post('/send-otp', (req, res) => {
  const { email } = req.body;
  if (!email) {
    return res.status(400).send('Email is required');
  }
  const otp = Math.floor(100000 + Math.random() * 900000); // Generate a 6-digit OTP
  otpStorage[email] = otp;

  // Mail options
  const mailOptions = {
    from: 'mannamnaresh9@gmail.com',
    to: email,
    subject: 'Your OTP Code',
    text: `Your OTP code is: ${otp}`, // Send the OTP in the email
  };

  // Send the email
  transporter.sendMail(mailOptions, (error, info) => {
    if (error) {
      console.error('Error sending email:', error);
      return res.status(500).send('Error sending OTP');
    }
    console.log('Email sent:', info.response);
    // Here you might want to save the OTP to your database for later verification
    // e.g., db.query('INSERT INTO otps (email, otp) VALUES (?, ?)', [email, otp]);
    
    res.status(200).send('OTP sent to ' + email);
  });
});

// Temporary storage for verified emails
let verifiedEmails = {}; // You can also use Redis or a database for production

verifiedEmails['fidbbf@gmail.com']=true;
app.post('/verify-otp', (req, res) => {
  const { email, otp } = req.body;
  if (!email || !otp) {
    return res.status(400).send('Email and OTP are required');
  }

  // Check if the OTP matches the stored OTP
  if (otpStorage[email] && otpStorage[email] == otp) {
    // OTP is valid, clear from storage
    delete otpStorage[email];

    // Store the verified email temporarily for future use
    verifiedEmails[email] = true; // Add the verified email to the storage

    // Respond with success
    res.status(200).send('OTP verified successfully');
  } else {
    // OTP is invalid or expired
    res.status(400).send('Invalid OTP');
  }
});

//updatting mail
app.post('/verify-mailotp', (req, res) => {
  const { email, otp,username } = req.body;
  if (!email || !otp || !username) {
    return res.status(400).send('Email and OTP are required');
  }

  // Check if the OTP matches the stored OTP
  //console.log(otpStorage[email]);
  //console.log(otp);
  if (otpStorage[email] && otpStorage[email] == otp) {
    // OTP is valid, clear from storage
    delete otpStorage[email];

    // Store the verified email temporarily for future use
    verifiedEmails[email] = true; // Add the verified email to the storage
    
    db.query('UPDATE users set email=? WHERE username=?',[email,username], 
         (err, result) => {
          //console.log(result);
          //console.log(err);
        if (err) {
          if (err.code === 'ER_DUP_ENTRY') {
            return res.status(300).json({ error: 'Cannot update email: Email already exists' });
        }
        else{
          console.log("Eroor inserting..");
          return res.status(500).json({ error: 'Error updating mail' });
        }
        }
        else{
          res.status(200).send('OTP verified successfully');
        }

        // Optionally, you can handle the successful insertion, e.g., return user info
        //console.log("User registered successfully");

      });
    // Respond with success
    //res.status(200).send('OTP verified successfully');
  } else {
    // OTP is invalid or expired
    res.status(400).send('Invalid OTP');
  }
}); 


// Fetch User Profile - Now using POST
app.post('/user-profile', (req, res) => {
  console.log('user profile requesting');
  const { username } = req.body; // Expect username to be in the request body
  db.query('SELECT users.*, user_profiles.* FROM users JOIN user_profiles ON user_profiles.username = users.username WHERE users.username = ?', [username], (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Database error' });
    }
    if (results.length > 0) {
      //console.log(results[0]);
      res.status(200).json(results[0]);
    } else {
      res.status(404).json({ error: 'User not found' });
    }
  });
});


// Update User Profile
app.post('/update-profile', (req, res) => {
  console.log('requesting update');
  const { username, education, phone_number,dob } = req.body;
  const query = `
    UPDATE user_profiles 
    SET  dob = ?, education = ?, phone_number = ? 
    WHERE username = ?
  `;
  db.query(query, [dob, education, phone_number, username], (err, results) => {
    if (err) {
      //console.log(err);
      return res.status(500).json({ error: 'Database error' });
    }
    return res.status(200).json({ message: 'Profile updated successfully' });
  });
});

// POST route to check if username exists
app.post('/check-username', (req, res) => {
  const { username, password, email } = req.body; // Include email in the destructured body

  // Check if the username exists
  db.query('SELECT * FROM users WHERE username = ?', [username], (err, result) => {
    if (err) {
      return res.status(500).json({ error: 'Database query error' });
    }
    
    if (result.length > 0) {
      // Username already exists
      console.log("Username exists");
      return res.json({ exists: true });
    } else {
      // Username does not exist, insert new user
      db.query('INSERT INTO users (username, password, email) VALUES (?, ?, ?)', 
        [username, password, email], (err, result) => {
        if (err) {
          console.log("Eroor inserting..");
          return res.status(500).json({ error: 'Error inserting user' });
        }

        // Optionally, you can handle the successful insertion, e.g., return user info
        console.log("User registered successfully");
        
        // Return response indicating the username does not exist
        return res.json({ exists: false });
      });
    }
  });
});

// Route to check if a user exists
app.post('/check_profile', (req, res) => {
  const { username } = req.body;
console.log('profile checking');
  if (!username) {
    return res.status(400).json({ message: 'Username is required' });
  }

  const query = 'SELECT COUNT(*) AS count FROM user_profiles WHERE username = ?';
  db.query(query, [username], (err, results) => {
    if (err) {
      console.error('Error executing query:', err.stack);
      return res.status(500).json({ message: 'Server error' });
    }

    const count = results[0].count;

    if (count === 1) {
      res.status(201).json({ exists: true, message: 'User exists' });
    } else {
      res.status(200).json({ exists: false, message: 'User does not exist' });
    }
  });
});


// Login route
app.post('/login', (req, res) => {
  const { username, password } = req.body;

  // Check if the username exists
  db.query('SELECT * FROM users WHERE username = ?', [username], (err, results) => {
    if (err) {
      console.log("database error");
      return res.status(500).json({ message: 'Database error', error: err });
    }

    if (results.length === 0) {
      console.log("username not found");
      return res.status(404).json({ message: 'Username not found' });
    }

    const user = results[0];

    // Check if the password is correct
    if (user.password !== password) {
      console.log("invalid password");
      return res.status(401).json({ message: 'Incorrect password' });
    }

    // Successful login
    return res.status(200).json({ message: 'Login successful', user });
  });
});


// Route to handle profile submission
app.post('/api/profile', (req, res) => {
  const { username, full_name, phone_number, gender, education, dob, courses_to_learn, courses_known } = req.body;

  // Insert into user_profiles table
  const userProfileQuery = 'INSERT INTO user_profiles (username, full_name, phone_number, gender, education, dob) VALUES (?, ?, ?, ?, ?, ?)';
  db.query(userProfileQuery, [username, full_name, phone_number, gender, education, dob], (err, result) => {
      if (err) {
          console.error('Error inserting user profile:', err);
          return res.status(500).json({ message: 'Error inserting user profile', error: err });
      }

      // Insert courses to user_courses table
      const userCoursesQueries = [];
      courses_known.forEach(course => {
          const userCourseQuery = 'INSERT INTO user_courses (username, courses_learned) VALUES (?, ?)';
          userCoursesQueries.push(new Promise((resolve, reject) => {
              db.query(userCourseQuery, [username, course], (err, result) => {
                  if (err) {
                      console.error('Error inserting course:', err);
                      reject(err);
                  } else {
                      resolve(result);
                  }
              });
          }));
      });

      courses_to_learn.forEach(course => {
        const userCourseQuery = 'INSERT INTO user_learning_courses (username, courses_learning) VALUES (?, ?)';
        userCoursesQueries.push(new Promise((resolve, reject) => {
            db.query(userCourseQuery, [username, course], (err, result) => {
                if (err) {
                    console.error('Error inserting course:', err);
                    reject(err);
                } else {
                    resolve(result);
                }
            });
        }));
    });

      Promise.all(userCoursesQueries)
          .then(() => {
              res.status(200).json({ message: 'Profile and courses added successfully' });
          })
          .catch(err => {
              console.error('Error inserting user courses:', err);
              res.status(500).json({ message: 'Error inserting user courses', error: err });
          });
  });
});


// Get users who are learning
app.get('/users/learning', (req, res) => {
  // Query the database for users who have already learnt
  const course = req.query.course; // Get the course from the query parameters
  const username = req.query.username;
  //console.log(username);

  // Prepare the SQL query to fetch learnt users based on the course
  const query = 'SELECT username FROM user_learning_courses WHERE courses_learning = ? AND username != ?';

  db.query(query, [course,username], (err, results) => {
    if (err) {
      console.error('Error fetching learnt users:', err); // Log the error for debugging
      return res.status(500).send('Error fetching data');
    }
    
    //console.log('Learning Users:', results); // Print results to the console for debugging
    res.json(results); // Send the results back to the client
  });
});


// Get users who have already learnt
app.get('/users/learnt', (req, res) => {
  // Query the database for users who have already learnt
  const course = req.query.course; // Get the course from the query parameters
  const username = req.query.username;
  //console.log(username);

  // Prepare the SQL query to fetch learnt users based on the course
  const query = 'SELECT username FROM user_courses WHERE courses_learned = ?  AND username != ?';

  db.query(query, [course,username], (err, results) => {
    if (err) {
      console.error('Error fetching learnt users:', err); // Log the error for debugging
      return res.status(500).send('Error fetching data');
    }
    
    //console.log('Learnt Users:', results); // Print results to the console for debugging
    res.json(results); // Send the results back to the client
  });
});

// Endpoint to handle bond requests
app.post('/request-bond', (req, res) => {
  const { from, to, course, request_text } = req.body; // Include request_text

  const query = 'INSERT INTO requests (request_from, request_to, course, additional_info) VALUES (?, ?, ?, ?)';
  
  db.query(query, [from, to, course, request_text], (error, results) => {
    if (error) {
      console.error('Error saving bond request:', error);
      return res.status(500).json({ message: 'Failed to save bond request.' });
    }
    res.status(200).json({ message: 'Bond request saved successfully!' });
  });
});

app.get('/api/friends', (req, res) => {
  const { username } = req.query;

  if (!username) {
    return res.status(400).json({ error: 'Username is required' });
  }
  //const query = 'SELECT user2, course FROM friends WHERE user1 = ?'; 
  const query = `
    SELECT 
        CASE 
            WHEN user1 = ? THEN user2 
            ELSE user1 
        END AS username,
        course 
    FROM friends 
    WHERE user1 = ? OR user2 = ?;
`;
  db.query(query, [username,username,username], (error, results) => {
    if (error) {
      console.error('Error fetching data:', error);
      res.status(500).json({ error: 'Database query failed' });
    } else {
      //console.log(results);
      res.json(results);
    }
  });
});

app.get('/api/requests',(req,res) =>{
  const{ username }=req.query;
  if (!username) {
    return res.status(400).json({ error: 'Username is required' });
  }

  const query='SELECT request_from,request_to,course,status,additional_info AS text FROM requests where request_from = ? OR request_to = ? ORDER BY request_id DESC;';
  db.query(query,[username,username],(error,results)=>{
    if (error) {
      console.error('Error fetching data:', error);
      res.status(500).json({ error: 'Database query failed' });
    } else {
      //console.log(results);
      res.json(results);
    }
  });
});

app.post('/api/request', (req, res) => {
  const { from, to, course, status } = req.body;

  if(status=='approved'){
    const qw='INSERT INTO friends(user1,user2,course) values(?,?,?);';
    db.query(qw,[from,to,course],(error,results) => {
      if(error){
        console.error('Error processing request:',error);
        return res.status(500).json({message:'sever error'});
      }
    })
  }
  // Update the status of the request in the database
  const query = 'UPDATE requests SET status = ? WHERE request_from = ? AND request_to = ? AND course = ?';

  db.query(query, [status, from, to, course], (error, results) => {
    if (error) {
      console.error('Error updating request:', error);
      return res.status(500).json({ message: 'Server error' });
    }
    res.status(200).json({ message: 'Request processed' });
  });
  // Optionally, you could remove the request from the database here
});

// app.post('/api/messages', (req, res) => {
//   const { username, course } = req.body;
//   if (!username|| !course) {
//     return res.status(400).json({ error: 'Username is required' });
//   }
//   //const query = 'SELECT user2, course FROM friends WHERE user1 = ?'; 
//   const query = `
//     SELECT 
//         sender AS username,
//         message_content AS text 
//     FROM messages 
//     WHERE (sender = ? OR receiver = ?) AND course=?;
// `;
//   db.query(query, [username,username,course], (error, results) => {
//     if (error) {
//       //console.log("EEEe");
//       console.error('Error fetching data:', error);
//       res.status(500).json({ error: 'Database query failed' });
//     } else {
//       //console.log(results);
//       //console.log('messages sent');
//       res.json(results);
//     }
//   });
// });

// app.post('/api/send-message', (req, res) => {
//   const { sender, receiver, text, course } = req.body;

//   if (!sender || !receiver|| !text || !course) {
//     return res.status(400).json({ error: 'Username, text, and course are required' });
//   }

//   const query = `
//     INSERT INTO messages (sender, receiver, message_content, course)
//     VALUES (?, ?, ?, ?);
//   `;

//   // Assuming you want to send the message from the logged-in user to their friend
//   db.query(query, [sender, receiver, text, course], (error, results) => {
//     if (error) {
//       console.error('Error sending message:', error);
//       return res.status(500).json({ error: 'Failed to send message' });
//     } else {
//       //console.log('Message sent successfully');
//       res.status(200).json({ message: 'Message sent successfully' });
//     }
//   });
// });

app.post('/api/upload', upload.single('file'), async (req, res) => {
  const { sender, receiver, course, text } = req.body; // Get data from the request body

  // Check if the file was uploaded
  if (!req.file) {
    return res.status(400).json({ message: 'File upload failed. No file uploaded.' });
  }

  // Get file information
  const { originalname, path: tempPath } = req.file;
  const fileUrl = `/uploads/${originalname}`; // URL to access the file
  const permanentPath = path.join(__dirname, 'public/uploads', originalname); // Permanent directory path
  fs.renameSync(tempPath, permanentPath); // Move file to permanent directory

  try {
    // Insert the message into the messages table
    const messageQuery = 'INSERT INTO messages (sender, receiver, course, text) VALUES (?, ?, ?, ?)';
    db.query(messageQuery, [sender, receiver, course, text], (err, result) => {
      if (err) {
        console.error('Error inserting message:', err);
        return res.status(500).json({ message: 'Failed to save message.' });
      }

      const messageId = result.insertId; // Get the inserted message ID

      // Insert the file information into the files table
      const fileQuery = 'INSERT INTO files (filename, url, message_id) VALUES (?, ?, ?)';
      db.query(fileQuery, [originalname, fileUrl, messageId], (err) => {
        if (err) {
          console.error('Error inserting file:', err);
          return res.status(500).json({ message: 'Failed to save file.' });
        }

        res.status(200).json({ message: 'File uploaded successfully!' });
      });
    });
  } catch (error) {
    console.error('Error saving data:', error);
    res.status(500).json({ message: 'Failed to save data.' });
  }
});

// Fetch messages endpoint
app.post('/api/messages', (req, res) => {
  const { sender, receiver, course } = req.body;
  //console.log(sender,receiver,course);

  if (!sender || !receiver || !course) {
    return res.status(400).json({ error: 'Username and course are required' });
  }

  const query = `
    SELECT 
      m.id AS message_id,
      m.sender AS username,
      m.message_content AS text,
      f.file_name AS filename,
      f.file_path AS filePath
    FROM messages m
    LEFT JOIN files f ON m.id = f.message_id
    WHERE ((m.sender = ? AND m.receiver = ?) OR (m.sender = ? AND m.receiver = ?)) AND m.course = ?;
  `;

  db.query(query, [sender, receiver, receiver, sender, course], (error, results) => {
    if (error) return res.status(500).send(error.message);
    //console.log('hi');
    //console.log(results);

    const messages = results.reduce((acc, row) => {
      // Find existing message object with the same message_id
      const existingMessage = acc.find(msg => msg.message_id === row.message_id);
      
      if (existingMessage) {
        // Add file if the row contains file information
        if (row.filename) {
          existingMessage.files.push({
            filename: row.filename,
            filePath: row.filePath // Update to filePath
          });
        }
      } else {
        // Add new message object to accumulator
        acc.push({
          message_id: row.message_id,
          username: row.username,
          text: row.text,
          files: row.filename ? [{ filename: row.filename, filePath: row.filePath }] : []
        });
      }
      //console.log('g'+acc);
      return acc;
    }, []);
    //console.log('m'+messages);
    return res.status(200).json(messages);
  });
});

// Send message endpoint
app.post('/api/send-message', upload.single('file'), (req, res) => {
  const { sender, receiver, text, course } = req.body;
  const filePath = req.file ? `uploads/${req.file.originalname}` : null; // Get the file path

  if (!sender || !receiver || !course) {
    return res.status(400).json({ error: 'Sender, receiver, and course are required' });
  }

  const query = `
    INSERT INTO messages (sender, receiver, message_content, course)
    VALUES (?, ?, ?, ?);
  `;

  db.query(query, [sender, receiver, text, course], (error, results) => {
    if (error) {
      console.error('Error sending message:', error);
      return res.status(500).json({ error: 'Failed to send message' });
    }

    const messageId = results.insertId; // Get the ID of the newly created message

    // If a file is uploaded, save its path in the database
    if (filePath) {
      const fileName = req.file.originalname;

      const fileQuery = `
        INSERT INTO files (message_id, file_name, file_path)
        VALUES (?, ?, ?);
      `;

      db.query(fileQuery, [messageId, fileName, filePath], (fileError) => {
        if (fileError) {
          console.error('Error saving file path:', fileError);
          return res.status(500).json({ error: 'Failed to save file path' });
        }
      });
    }
    
    // Respond with the new message details (optional)
    return res.status(200).json({ messageId, sender, receiver, text, course, filePath });
  });
});

app.get('/api/download/:filename', (req, res) => {
  console.log("backend request");
  const filename = req.params.filename;
  const filePath = path.join(__dirname, 'uploads', filename);

  res.download(filePath, (err) => {
    if (err) {
      console.error('Error sending file:', err);
      res.status(500).send('Error downloading file.');
    }
  });
});

// Endpoint for viewing a file
app.get('/api/view/uploads/:filename', (req, res) => {
  const filename = req.params.filename;
  console.log('Requested filename:', filename); // Log the requested filename
  const filepath = path.join(__dirname, 'uploads', filename); // Ensure correct path to uploads directory
  console.log('Filepath to send:', filepath); // Log the filepath being sent

  res.sendFile(filepath, (err) => {
    if (err) {
      console.error('Error sending file:', err);
      res.status(err.status).end();
    }
  });
});




// Start the server
const PORT = process.env.PORT || 3000;
app.listen(port,'0.0.0.0', () => {
  console.log(`Server running on port ${port}`);
});
