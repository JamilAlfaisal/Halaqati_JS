import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, CreateDateColumn } from "typeorm";
import { Class } from "./Class";
import { User } from "./User"

@Entity()
export class Event {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column({ type: "text", nullable: false})
  title!: string;

  @Column({ type: "text", nullable: true })
  description!: string;

  @CreateDateColumn()
  createdAt!: Date;
  
  @Column({ type: "datetime", nullable: true })
  dueDate!: Date;

  @ManyToOne(() => User, (user) => user.events)
  teacher!: User;

  @ManyToOne(() => Class, (classroom) => classroom.events)
  class!: Class;
}
