import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    ManyToOne,
    JoinColumn,
    Unique,
    Check
} from 'typeorm';
import { Student } from './Student';
import { User } from './User';
import { Class } from './Class';

@Entity('page_progress')
@Unique(['studentId', 'pageNumber'])
@Check(`"page_number" >= 1 AND "page_number" <= 604`)
export class PageProgress {
    @PrimaryGeneratedColumn('uuid')
    id!: string;

    @Column({ name: 'page_number', type: 'smallint' })
    pageNumber!: number;

    @Column({ name: 'marking_date', type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
    markingDate!: Date;

    @Column({ name: 'review_date', type: 'timestamp', nullable: true })
    reviewDate!: Date;

    @Column({ name: 'student_id' })
    studentId!: string;

    @Column({ name: 'teacher_id' })
    teacherId!: string;

    @Column({ name: 'class_id', nullable: true })
    classId!: string | null;

    @ManyToOne(() => Student, { onDelete: 'CASCADE' })
    @JoinColumn({ name: 'student_id' })
    student!: Student;

    @ManyToOne(() => User, { onDelete: 'RESTRICT' })
    @JoinColumn({ name: 'teacher_id' })
    teacher!: User;

    @ManyToOne(() => Class, { onDelete: 'SET NULL' })
    @JoinColumn({ name: 'class_id' })
    class!: Class | null;
} 