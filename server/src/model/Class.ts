import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, OneToMany } from "typeorm";
import { User } from "./User";
import { Attendance } from "./Attendance";
import { StudyIn } from "./Study_in";
import { Assignment } from "./Assignment";
import { Event } from "./Events";


@Entity()
export class Class {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column({ type: "text", nullable: false })
  name!: string;

  @Column({ type: "text", nullable: true })
  description!: string;

  @Column({ type: "text", nullable: true })
  location!: string;

  @Column({ type: "simple-array", default:'' })
  days!: string[];

  @Column({ type: "time", nullable: true })
  startTime!: string;

  @Column({ type: "time", nullable: true })
  endTime!: string;

  @ManyToOne(() => User, (user) => user.classes)
  teacher!: User;

  @OneToMany(() => Attendance, (attendance) => attendance.class)
  attendances!: Attendance[];

  @OneToMany(() => StudyIn, (studyIn) => studyIn.class)
  studyInRecords!: StudyIn[];

  @OneToMany(() => Assignment, (assignment) => assignment.class)
  assignments!: Assignment[];

  @OneToMany(() => Event, (event) => event.class)
  events!: Event[];
}
