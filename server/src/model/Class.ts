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

  @Column()
  name!: string;

  @Column({ type: "text", nullable: true })
  description!: string;

  @Column()
  location!: string;

  @Column({ type: "simple-array" })
  days!: string[];

  @Column({ type: "datetime", nullable: true })
  startTime!: string;

  @Column({ type: "datetime", nullable: true })
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
