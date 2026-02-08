import { Entity, PrimaryGeneratedColumn, Column, ManyToOne } from "typeorm";
import { Student } from "./Student";
import { Assignment } from "./Assignment";

@Entity()
export class HaveAssignment {
  @PrimaryGeneratedColumn()
  id!: number;

  @ManyToOne(() => Student, (Student) => Student.haveAssignment, {onDelete:"CASCADE"})
  student!: Student;

  @ManyToOne(() => Assignment, (assignment) => assignment.haveAssignment, { onDelete: 'CASCADE' })
  assignment!: Assignment;

  @Column({ type: "boolean", default: false })
  isComplete!: boolean;
}
