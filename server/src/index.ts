import express, { Request, Response } from "express";
import "reflect-metadata";
import { AppDataSource } from "./data-source";
import * as admin from 'firebase-admin';
import dotenv from "dotenv";
import cors from "cors";


const serviceAccount = require("../service_key.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

export const messaging = admin.messaging();

dotenv.config();
const app = express();
const PORT = 3000;

// Allow the admin dashboard dev server (and preview) to reach the API.
// In production, replace with your actual deployed dashboard origin.
const allowedOrigins = [
  'http://localhost:5173',
  'http://localhost:4173',
  ...(process.env.DASHBOARD_ORIGIN ? [process.env.DASHBOARD_ORIGIN] : [])
];

app.use(cors({
  origin: (origin, callback) => {
    // Allow requests with no origin (e.g. mobile apps, curl, Postman)
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error(`CORS: origin ${origin} not allowed`));
    }
  },
  credentials: true,
}));

app.use(express.json());

AppDataSource.initialize()
  .then(() => {
    console.log("✅ Database connected");

    app.listen(PORT, () => {
      console.log(`🚀 Server running at http://localhost:${PORT}`);
    });
  })
  .catch((err) => {
    console.error("❌ Database connection failed:", err);
  });



import authRouter from './router/authRouter';
import classRouter from './router/classRouter';
import attendanceRouter from './router/attendanceRouter';
import studentClassRouter from './router/studentClassRouter';
import juzRouter from './router/juzRouter';
import assignmentRouter from './router/assignmentRouter';
import eventRouter from './router/evenRouter';
import aboutUsRouter from './router/aboutUsRouter';
import pagesRouter from './router/pagesRouter';
import gradesRouter from './router/gradesRouter';


app.use('/api/auth', authRouter);
app.use('/api/class', classRouter);
app.use('/api/attendance', attendanceRouter);
app.use('/api/student_class', studentClassRouter);
app.use('/api/update_student', juzRouter);
app.use('/api/assignment', assignmentRouter);
app.use('/api/event', eventRouter);
app.use('/api/about_us', aboutUsRouter);
app.use('/api/pages', pagesRouter);
app.use('/api/grades', gradesRouter);