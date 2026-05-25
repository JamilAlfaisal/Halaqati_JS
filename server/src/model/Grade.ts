import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    CreateDateColumn,
    ManyToOne,
    JoinColumn,
    Check
} from 'typeorm';
import { User } from './User';       // Assuming your Teacher/User entity is here
import { Student } from './Student';   // Assuming Student entity
import { Class } from './Class';       // Assuming Class entity
import { Assignment } from './Assignment';

@Entity('grades')
@Check(`"weight" IN (1, 2, 3)`) // Enforces the discrete domain at database level
@Check(`"score" >= 0 AND "score" <= 20`) // Capped at 20
export class Grade {
    @PrimaryGeneratedColumn('uuid')
    id!: string;

    @Column({ type: 'decimal', precision: 4, scale: 2 })
    score!: number; // Your fixed score out of 20

    @Column({ type: 'smallint' })
    weight!: number; // Domain restricted to 1, 2, or 3

    @Column({ type: 'text', nullable: true })
    description!: string;

    @CreateDateColumn({ name: 'date_time' })
    dateTime!: Date;

    // Relations
    @ManyToOne(() => User, { onDelete: 'SET NULL' })
    @JoinColumn({ name: 'teacher_id' })
    teacher!: User; // The teacher who took the grade

    @ManyToOne(() => Student, { onDelete: 'CASCADE' })
    @JoinColumn({ name: 'student_id' })
    student!: Student;

    @ManyToOne(() => Class, { onDelete: 'CASCADE' })
    @JoinColumn({ name: 'class_id' })
    class!: Class;

    @ManyToOne(() => Assignment, { nullable: true, onDelete: 'SET NULL' })
    @JoinColumn({ name: 'assignment_id' })
    assignment?: Assignment | null; // Optional link for ad-hoc grading

}