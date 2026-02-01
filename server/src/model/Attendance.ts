import { Entity, PrimaryGeneratedColumn, ManyToOne, CreateDateColumn, ManyToMany } from "typeorm";
import { Class } from "./Class";
import { Student } from "./Student";
import { User } from "./User";

@Entity()
export class Attendance {
  
@PrimaryGeneratedColumn()
  id!: number;

  @CreateDateColumn({ type: "datetime", nullable: true })
  date!: Date;

  @ManyToOne(() => Class, (classroom) => classroom.attendances)
  class!: Class;

  @ManyToOne(() => User, (user) => user.attendancesCreated)
  teacher!: User;

  @ManyToMany(() => Student, (student) => student.attendance)
  students!: Student[];

}
