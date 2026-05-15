import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, Unique } from "typeorm";
import { Student } from "./Student";
import { Class } from "./Class";



@Entity()
@Unique(['student', 'class'])
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

  @Column({
    name: 'cumulative_grade',
    type: 'decimal',
    precision: 4,
    scale: 2,
    default: 0.00
  })
  cumulativeGrade!: number;

  @Column({
    name: 'total_weight_points',
    type: 'integer',
    default: 0
  })
  totalWeightPoints!: number;

}
