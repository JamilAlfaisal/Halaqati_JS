import {DataSource} from "typeorm";
import "reflect-metadata";
import { User } from "./model/User";
import { Student } from "./model/Student";
import { Class } from "./model/Class";
import { StudyIn } from "./model/Study_in";
import { Attendance } from "./model/Attendance";
import { Event } from "./model/Events";
import { Assignment } from "./model/Assignment";



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
    Assignment
  ],
  synchronize: true, // auto-create tables in dev
});
