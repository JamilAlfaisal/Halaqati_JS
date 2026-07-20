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
  
  @Column({ type: "date", nullable: true })
  dueDate!: Date;

  @Column({
    type: 'boolean',
    default: false,
  })
  confirmation!: boolean;

  @ManyToOne(() => User, (user) => user.events, {
    onDelete: "CASCADE"
  })
  teacher!: User;

  @ManyToOne(() => Class, (classroom) => classroom.events, {
    onDelete: "CASCADE"
  })
  class!: Class;
}
