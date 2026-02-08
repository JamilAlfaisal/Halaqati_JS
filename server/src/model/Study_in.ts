import { Entity, PrimaryGeneratedColumn, Column, ManyToOne } from "typeorm";
import { Student } from "./Student";
import { Class } from "./Class";



@Entity()
export class StudyIn {
  @PrimaryGeneratedColumn()
  id!: number;

  @ManyToOne(() => Student, s => s.studyIn)
  student!: Student;

  @ManyToOne(() => Class, c => c.studyInRecords)
  class!: Class;

  @Column({ type: "datetime", nullable: false })
  registeredAt!: Date;
}
