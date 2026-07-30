import { Entity, PrimaryGeneratedColumn, ManyToOne, CreateDateColumn, JoinTable, ManyToMany } from "typeorm";
import { Class } from "./Class";
import { Student } from "./Student";
import { User } from "./User";

@Entity()
export class Attendance {

  @PrimaryGeneratedColumn()
  id!: number;

  @CreateDateColumn({ type: "timestamp" })
  date!: Date;

  @ManyToOne(() => Class, (classroom) => classroom.attendances, {
    onDelete: "CASCADE"
  })
  class!: Class;

  @ManyToOne(() => User, (user) => user.attendancesCreated, {
    onDelete: "CASCADE"
  })
  teacher!: User;

  @ManyToMany(() => Student, (student) => student.attendance)
  @JoinTable({
    name: 'student_attendance',
    joinColumns: [{
      name: 'attendanceId',
      referencedColumnName: 'id',
      foreignKeyConstraintName: 'FK_15ed2cec4b795ab0c19087c5557',
    }],
    inverseJoinColumns: [{
      name: 'studentId',
      referencedColumnName: 'id',
    }],
  })
  students!: Student[];
}
