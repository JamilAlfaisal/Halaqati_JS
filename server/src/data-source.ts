import {DataSource} from "typeorm";
import "reflect-metadata";
import { User } from "./model/User";



export const AppDataSource = new DataSource({
  type: "mysql",
  host: "localhost",
  username: "root",
  port: 3306,
  password: "",
  database: "halaqati",
  entities: [User],
  synchronize: true, // auto-create tables in dev
});
