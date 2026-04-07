import { Entity, PrimaryGeneratedColumn, Column, ManyToOne } from "typeorm";
import { Student } from "./Student";
import { Class } from "./Class";



@Entity()
export class StudyIn {
  @PrimaryGeneratedColumn()
  id!: number;

  @ManyToOne(() => Student, s => s.studyIn, {
    onDelete: "CASCADE"
  })
  student!: Student;

  @ManyToOne(() => Class, c => c.studyInRecords, {
    onDelete: "CASCADE"
  })
  class!: Class;

  @Column({ type: "date" })
  registeredAt: Date = new Date();
}
