import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, ManyToMany, JoinTable, CreateDateColumn } from "typeorm";
import { Student } from "./Student";
import { User } from "./User";
import { Class } from "./Class";

@Entity()
export class Assignment {
  
  @PrimaryGeneratedColumn()
  id!: number;

  @Column()
  title!: string;

  @Column({ type: "text", nullable: true })
  description!: string;

  @Column({ type: "simple-array", nullable: true })
  pages!: number[];

  @Column({
    type: "enum",
    enum: ["Memorization", "Revision", "Reading"],
    default: "Memorization"
  })
  type!: "Memorization" | "Revision" | "Reading";

  @CreateDateColumn({ type: "datetime", nullable: true })
  createdAt!: Date;

  @Column({ type: "datetime", nullable: true })
  dueDate!: Date;

  @ManyToOne(() => User, (user) => user.assignments)
  teacher!: User;

  @ManyToOne(() => Class, (classroom) => classroom.assignments)
  class!: Class;

  @ManyToMany(() => Student, (student) => student.assignments)
  @JoinTable({ name: "student_assignments" })
  students!: Student[];
}
