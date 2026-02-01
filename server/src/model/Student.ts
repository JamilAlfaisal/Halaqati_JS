import { OneToOne, JoinColumn, Column, ManyToMany, OneToMany, JoinTable, Entity, PrimaryGeneratedColumn } from "typeorm";
import { User } from "./User";
import { Assignment } from "./Assignment";
import { StudyIn } from "./Study_in";
import { Attendance } from "./Attendance";

@Entity("STUDENT")
export class Student{

  @PrimaryGeneratedColumn()
  id!: number;

  @OneToOne(() => User, { cascade: true, onDelete: 'CASCADE' })
  @JoinColumn({ name: "user_id" })
  user!: User;

  @Column({ type: "simple-array", nullable: true })
  memorized_juz!: string[];

  @ManyToMany(() => Assignment, (assignment) => assignment.students)
  assignments!: Assignment[];

  @OneToMany(() => StudyIn, (studyIn) => studyIn.student)
  studyIn!: StudyIn[];

  @ManyToMany(() => Attendance, (attendance) => attendance.students)
  @JoinTable({ name: "student_attendance" })
  attendance!: Attendance[];
  
}
