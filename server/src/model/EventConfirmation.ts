import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, CreateDateColumn } from "typeorm";
import { Event } from "./Events";
import { Student } from "./Student";

@Entity()
export class EventConfirmation {
  @PrimaryGeneratedColumn()
  id!: number;

  @ManyToOne(() => Event, { onDelete: "CASCADE" })
  event!: Event;

  @ManyToOne(() => Student, { onDelete: "CASCADE" })
  student!: Student;

  @Column({
    type: 'boolean',
  })
  isConfirmed!: boolean; // true for YES, false for NO

  @CreateDateColumn()
  createdAt!: Date;
}
