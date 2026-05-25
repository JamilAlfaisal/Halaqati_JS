import { OneToOne, JoinColumn, Column, ManyToMany, OneToMany, JoinTable, Entity, PrimaryColumn } from "typeorm";
import { User } from "./User";
import { Assignment } from "./Assignment";
import { StudyIn } from "./Study_in";
import { Attendance } from "./Attendance";
import { HaveAssignment } from "./Have_assignment";
import { Grade } from "./Grade";

@Entity("STUDENT")
export class Student {

  @PrimaryColumn()
  id!: number;

  @OneToOne(() => User, { cascade: true, onDelete: 'CASCADE' })
  @JoinColumn({ name: "user_id" })
  user!: User;

  @Column({ type: "simple-array", nullable: true, default: '' })
  memorized_juz!: string[];

  @OneToMany(() => HaveAssignment, (haveAssignment) => haveAssignment.student)
  haveAssignment!: HaveAssignment[];

  @OneToMany(() => StudyIn, (studyIn) => studyIn.student)
  studyIn!: StudyIn[];

  @ManyToMany(() => Attendance, (attendance) => attendance.students)
  attendance!: Attendance[];

  @OneToMany(() => Grade, (grade) => grade.student)
  grades!: Grade[];
}