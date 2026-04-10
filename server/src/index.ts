import express, { Request, Response } from "express";
import "reflect-metadata";
import { AppDataSource } from "./data-source";
import * as admin from 'firebase-admin';
import dotenv from "dotenv";


const serviceAccount = require("../service_key.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

export const messaging = admin.messaging();

dotenv.config();
const app = express();
const PORT = 3000;

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

app.use('/api/auth', authRouter);
app.use('/api/class', classRouter);
app.use('/api/attendance', attendanceRouter);
app.use('/api/student_class', studentClassRouter);
app.use('/api/update_student', juzRouter);
app.use('/api/assignment', assignmentRouter);
app.use('/api/event', eventRouter); 