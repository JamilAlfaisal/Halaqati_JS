import { DataSource } from "typeorm";
import "reflect-metadata";
import { User } from "./model/User";
import { Student } from "./model/Student";
import { Class } from "./model/Class";
import { StudyIn } from "./model/Study_in";
import { Attendance } from "./model/Attendance";
import { Event } from "./model/Events";
import { Assignment } from "./model/Assignment";
import { HaveAssignment } from "./model/Have_assignment";
import { AboutUs } from "./model/About_us_model";


export const AppDataSource = new DataSource({
  type: "mysql",
  host: "localhost",
  username: "root",
  port: 3306,
  password: "",
  database: "halaqati",
  entities: [
    User,
    Student,
    Class,
    StudyIn,
    Attendance,
    Event,
    Assignment,
    HaveAssignment,
    AboutUs
  ],
  // synchronize: true,
  // dropSchema: true
});
