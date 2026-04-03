import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, OneToMany, JoinTable, CreateDateColumn } from "typeorm";
import { Student } from "./Student";
import { User } from "./User";
import { Class } from "./Class";
import { HaveAssignment } from "./Have_assignment";
@Entity()
export class Assignment {
  
  @PrimaryGeneratedColumn()
  id!: number;

  @Column()
  title!: string;

  @Column({ type: "text", nullable: true })
  description!: string;

  @Column({ type: "simple-array", nullable: true, default:''})
  pages!: number[];

  @Column({
    type: "enum",
    enum: ["Memorization", "Revision", "Reading"],
    default: "Memorization"
  })
  type!: "Memorization" | "Revision" | "Reading";

  @CreateDateColumn({ type: "datetime", nullable: true })
  createdAt!: Date;

  @Column({ type: "date", nullable: true })
  dueDate!: Date;

  @ManyToOne(() => User, (user) => user.assignments, {
    onDelete: "CASCADE"
  })
  teacher!: User;

  @ManyToOne(() => Class, (classroom) => classroom.assignments, {
    onDelete: "CASCADE"
  })
  class!: Class;

  @OneToMany(() => HaveAssignment, (HaveAssignment) => HaveAssignment.assignment)
  haveAssignment!: HaveAssignment[];
}
