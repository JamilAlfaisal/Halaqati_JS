import { Entity, PrimaryGeneratedColumn, Column, OneToMany, CreateDateColumn, TableInheritance, OneToOne } from "typeorm";
import { Event } from "./Events";
import { Attendance } from "./Attendance";
import { Assignment } from "./Assignment";
import { Class } from "./Class";
import { Student } from "./Student";


// This decorator enables inheritance. 'type' will store 'USER' or 'STUDENT'.
// @TableInheritance({ column: { type: "varchar", name: "type" } })
@Entity()
export class User {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column()
  name!: string;

  @Column({ unique: true })
  email!: string;

  @Column({ nullable: true })
  phone!: string;

  @Column({ type: "datetime", nullable: true })
  dob!: Date;

  @CreateDateColumn()
  createdAt!: Date;

  @Column({ select: false })
  password!: string;

  @Column({ nullable: true })
  picProfile!: string;
  
  @OneToOne(() => Student, (student) => student.user)
  student!: Student;

  // --- Relations (Shared by both Teachers/Users and Students) ---

  @OneToMany(() => Event, (event) => event.teacher)
  events!: Event[];

  @OneToMany(() => Assignment, (assignment) => assignment.teacher)
  assignments!: Assignment[];

  @OneToMany(() => Class, (classroom) => classroom.teacher)
  classes!: Class[];

  @OneToMany(() => Attendance, (a) => a.teacher)
  attendancesCreated!: Attendance[];
}