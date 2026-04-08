import { Request, Response } from 'express';
import { In, Between, MoreThanOrEqual } from 'typeorm';
import { AppDataSource } from '../data-source';
import { User } from '../model/User';
import { Student } from '../model/Student';
import { Class } from '../model/Class';
import { Attendance } from '../model/Attendance'
import { AuthRequest } from '../middleware/middleware';

export const takeAttendance = async (req: AuthRequest, res: Response) => {

    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    const userRepository = queryRunner.manager.getRepository(User);
    const classRepository = queryRunner.manager.getRepository(Class);
    const attendanceRepository = queryRunner.manager.getRepository(Attendance);
    const studentRepository = queryRunner.manager.getRepository(Student);

    try {
        const userId = req.user?.id;
        const role = req.user?.role;
        const classId = Number(req.params.id);

        if (!userId) {
            console.log("❌ http://localhost:3000/api/attendance/take");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if (role != "teacher") {
            console.log("❌ http://localhost:3000/api/attendance/take");
            return res.status(403).json({ message: "Forbidden" })
        }

        if (isNaN(classId)) {
            console.log("❌ http://localhost:3000/api/attendance/take");
            return res.status(400).json({ message: "Invalid class id" });
        }

        const teacher = await userRepository.findOneBy({ id: userId });

        if (!teacher) {
            console.log("❌ http://localhost:3000/api/attendance/take");
            return res.status(404).json({ message: "Teacher not found" });
        }

        const { studentIds } = req.body;

        if (!Array.isArray(studentIds) || studentIds.length === 0) {
            console.log("❌ http://localhost:3000/api/attendance/take");
            return res.status(400).json({ message: "studentIds must be a non-empty array" })
        }

        const existingClass = await classRepository.findOne({
            where: { id: classId },
            relations: ["teacher"],
        });

        if (!existingClass) {
            console.log("❌ http://localhost:3000/api/attendance/take");
            return res.status(404).json({ message: "Class not found" });
        }

        if (existingClass.teacher.id !== userId) {
            console.log("❌ http://localhost:3000/api/attendance/take");
            return res.status(403).json({ message: "Not class owner" });
        }

        const students = await studentRepository.findBy({ id: In(studentIds) });

        if (students.length != studentIds.length) {
            console.log("❌ http://localhost:3000/api/attendance/take");
            return res.status(400).json({ message: "One or more students not found" });
        }

        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const tomorrow = new Date(today);
        tomorrow.setDate(today.getDate() + 1);

        // Between in TypeORM is same as BETWEEN in sql it return 
        // all values between two ranges
        const existingAttendance = await attendanceRepository.findOne({
            where: {
                class: { id: classId },
                teacher: { id: userId },
                date: Between(today, tomorrow)
            }
        });

        if (existingAttendance) {
            console.log("❌ http://localhost:3000/api/attendance/take");
            return res.status(409).json({ message: "Attendace already taken for this class today" })
        }

        // not here instead of class we can pass id and same for teacher
        // {id:teacher.id} as any
        const attendance = attendanceRepository.create({
            class: existingClass,
            teacher: teacher,
            students
        });

        await attendanceRepository.save(attendance);

        await queryRunner.commitTransaction();

        console.log("✅ http://localhost:3000/api/attendance/take");
        return res.status(201).json({
            attendanceId: attendance.id,
            date: attendance.date,
            classId: existingClass.id,
            presentStudents: students.map((s) => s.id),
        });

    } catch (e) {
        await queryRunner.rollbackTransaction();
        console.log("❌ http://localhost:3000/api/attendance/take");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to take attendance" });
    } finally {
        await queryRunner.release();
    }

}

export const updateAttendance = async (req: AuthRequest, res: Response) => {
    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    const userRepository = queryRunner.manager.getRepository(User);
    const classRepository = queryRunner.manager.getRepository(Class);
    const attendanceRepository = queryRunner.manager.getRepository(Attendance);
    const studentRepository = queryRunner.manager.getRepository(Student);
    try {
        const userId = req.user?.id;
        const role = req.user?.role;
        const attendanceId = Number(req.params.id);

        if (!userId) {
            console.log("❌ http://localhost:3000/api/attendance/update");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if (role != "teacher") {
            console.log("❌ http://localhost:3000/api/attendance/update");
            return res.status(403).json({ message: "Forbidden" })
        }

        if (isNaN(attendanceId)) {
            console.log("❌ http://localhost:3000/api/attendance/update");
            return res.status(400).json({ message: "Invalid attendance id" });
        }

        const teacher = await userRepository.findOneBy({ id: userId });

        if (!teacher) {
            console.log("❌ http://localhost:3000/api/attendance/update");
            return res.status(404).json({ message: "Teacher not found" });
        }

        const { studentIds } = req.body;

        if (!Array.isArray(studentIds) || studentIds.length === 0) {
            console.log("❌ http://localhost:3000/api/attendance/update");
            return res.status(400).json({ message: "studentIds must be a non-empty array" })
        }

        const existingAttendance = await attendanceRepository.findOne({
            where: { id: attendanceId },
            relations: ["teacher", "students", "class"],
        });

        if (!existingAttendance) {
            console.log("❌ http://localhost:3000/api/attendance/update");
            return res.status(404).json({ message: "Attendance not found" });
        }

        if (existingAttendance.teacher.id !== userId) {
            console.log("❌ http://localhost:3000/api/attendance/update");
            return res.status(403).json({ message: "Not class owner" });
        }

        const today = new Date();

        const todayString = today.toISOString().split('T')[0];

        const recordDate = existingAttendance.date.toISOString().split('T')[0];

        console.log("Record Date:", recordDate);
        console.log("Today's Date:", todayString);

        if (recordDate !== todayString) {
            console.log("❌ Attendance update rejected: Date mismatch.");
            return res.status(409).json({
                message: "Attendance can only be updated on the same day",
            });
        }


        const students = await studentRepository.find({
            where: { id: In(studentIds) },
            relations: ['studyIn', 'studyIn.class']
        });

        if (students.length !== studentIds.length) {
            console.log("❌ http://localhost:3000/api/attendance/update");
            return res.status(400).json({
                message: "One or more students not found",
            });
        }

        const validStudents = students.filter((student) => {
            return student.studyIn?.some((c) => {
                return c.class.id == existingAttendance.class?.id
            });
        }
        );

        if (validStudents.length !== students.length) {
            console.log("❌ http://localhost:3000/api/attendance/update");
            return res.status(400).json({
                message: "Some students are not enrolled in this class",
            });
        }

        existingAttendance.students = validStudents;

        await queryRunner.manager.save(existingAttendance);
        await queryRunner.commitTransaction();

        console.log("✅ http://localhost:3000/api/attendance/update");
        return res.status(200).json({
            attendanceId: existingAttendance.id,
            date: existingAttendance.date,
            classId: existingAttendance.class.id,
            presentStudents: existingAttendance.students.map((s) => s.id),
        });

    } catch (e) {
        await queryRunner.rollbackTransaction();
        console.log("❌ http://localhost:3000/api/attendance/update");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to update attendance" });
    } finally {
        await queryRunner.release();
    }
}

export const deleteAttendance = async (req: AuthRequest, res: Response) => {
    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    const attendanceRepository = queryRunner.manager.getRepository(Attendance);

    try {
        const userId = req.user?.id;
        const role = req.user?.role;
        const attendanceId = Number(req.params.id);

        if (!userId) {
            console.log("❌ http://localhost:3000/api/attendance/delete");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if (role != "teacher") {
            console.log("❌ http://localhost:3000/api/attendance/delete");
            return res.status(403).json({ message: "Forbidden" })
        }

        if (isNaN(attendanceId)) {
            console.log("❌ http://localhost:3000/api/attendance/delete");
            return res.status(400).json({ message: "Invalid attendance id" });
        }

        const existingAttendance = await attendanceRepository.findOne({
            where: { id: attendanceId },
            relations: ['teacher']
        });

        if (!existingAttendance) {
            console.log("❌ http://localhost:3000/api/attendance/delete");
            return res.status(404).json({ message: 'The attendacne record does not exist' })
        }

        if (existingAttendance.teacher.id != userId) {
            console.log("❌ http://localhost:3000/api/attendance/delete");
            return res.status(403).json({ message: "Not attendance owner" });
        }

        await queryRunner.manager
            .createQueryBuilder()
            .delete()
            .from("student_attendance")
            .where("attendanceId = :attendanceId", { attendanceId })
            .execute();

        await attendanceRepository.delete(attendanceId);
        await queryRunner.commitTransaction();

        console.log("✅ http://localhost:3000/api/attendance/delete");
        return res.status(204).send();
    } catch (e) {
        await queryRunner.rollbackTransaction();
        console.log("❌ http://localhost:3000/api/attendance/delete");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to delete attendance" });
    } finally {
        await queryRunner.release();
    }
}

export const getClassAttendanceForTeacher = async (req: AuthRequest, res: Response) => {

    const attendanceRepository = AppDataSource.getRepository(Attendance);

    try {
        const userId = req.user?.id;
        const role = req.user?.role;
        const classId = Number(req.params.id);

        const offset = parseInt(req.query.offset as string) || 0;
        const limit = parseInt(req.query.limit as string) || 10;

        if (!userId) {
            console.log("❌ http://localhost:3000/api/attendance/get");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if (role != "teacher") {
            console.log("❌ http://localhost:3000/api/attendance/get");
            return res.status(403).json({ message: "Forbidden" })
        }

        if (isNaN(classId)) {
            console.log("❌ http://localhost:3000/api/attendance/get");
            return res.status(400).json({ message: "Invalid class id" });
        }

        const [attendances, total] = await attendanceRepository.findAndCount({
            where: {
                teacher: { id: userId },
                class: { id: classId }
            },
            relations: ['students', 'students.user'],
            order: { date: "DESC" }, // 🔥 important
            skip: offset,
            take: limit,
        });



        const attedanceList = attendances.map((attendance) => ({
            id: attendance.id,
            date: attendance.date,
            students: attendance.students.map((student) => {
                const { password: _, ...userWithoutPassword } = student.user
                return { ...userWithoutPassword, memorized_juz: student.memorized_juz }
            })
        }))

        console.log("✅ http://localhost:3000/api/attendance/get");
        return res.status(200).json({
            total,
            offset,
            limit,
            attendance: attedanceList
        })
    } catch (e) {
        console.log("❌ http://localhost:3000/api/attendance/get");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to get attendances" });
    }
}

export const getAttendanceDetails = async (req: AuthRequest, res: Response) => {

    const attendanceRepository = AppDataSource.getRepository(Attendance);

    try {
        const userId = req.user?.id;
        const role = req.user?.role;
        const attendanceId = Number(req.params.id);

        if (!userId) {
            console.log("❌ http://localhost:3000/api/details/get");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if (role != "teacher") {
            console.log("❌ http://localhost:3000/api/details/get");
            return res.status(403).json({ message: "Forbidden" })
        }

        if (isNaN(attendanceId)) {
            console.log("❌ http://localhost:3000/api/details/get");
            return res.status(400).json({ message: "Invalid class id" });
        }

        const attendance = await attendanceRepository.findOne({
            where: {
                id: attendanceId,
                teacher: { id: userId },
            },
            relations: ['students', 'students.user']
        });


        if (!attendance) {
            console.log("❌ http://localhost:3000/api/attendance/details");
            return res.status(404).json({ message: "Attendance record not found" })
        }

        const students = attendance.students;

        const attendeeWithoutPassword = students.map((student) => {
            return {
                studentId: student.id,
                ...student.user,
                memorizedJuz: student.memorized_juz
            }
        });

        const attendanceDetails = {
            id: attendance.id,
            date: attendance.date,
            students: attendeeWithoutPassword
        }

        console.log("attendanceDetails", attendanceDetails);


        console.log("✅ http://localhost:3000/api/attendance/details");
        return res.status(200).json({
            attendanceDetails
        })

    } catch (e) {
        console.log("❌ http://localhost:3000/api/attendance/details");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to get details" });
    }
}


export const getAttendanceStatsByClass = async (req: AuthRequest, res: Response) => {
    const attendanceRepository = AppDataSource.getRepository(Attendance);
    const classRepository = AppDataSource.getRepository(Class);

    try {
        console.log("✅ http://localhost:3000/api/attendance/stats/:classId");
        const userId = req.user?.id;
        const role = req.user?.role;
        const classId = Number(req.params.classId);
        const fromDate = req.query.fromDate ? new Date(req.query.fromDate as string) : null;

        // 🔐 Auth checks
        if (!userId) {
            return res.status(401).json({ message: "Unauthorized" });
        }

        if (role !== "teacher") {
            return res.status(403).json({ message: "Forbidden" });
        }

        if (isNaN(classId)) {
            return res.status(400).json({ message: "Invalid class id" });
        }

        // 🔐 Ownership check
        const ownsClass = await classRepository.exist({
            where: {
                id: classId,
                teacher: { id: userId },
            },
        });

        if (!ownsClass) {
            return res.status(403).json({ message: "You do not own this class" });
        }

        // 📡 Fetch attendances
        const attendances = await attendanceRepository.find({
            where: {
                class: { id: classId },
                ...(fromDate && { date: MoreThanOrEqual(fromDate) }),
            },
            relations: ['students', 'students.user'],
        });

        // 🧠 Count per student
        const studentMap = new Map<number, {
            studentId: number,
            name: string,
            attendanceCount: number
        }>();

        attendances.forEach(att => {
            att.students.forEach(student => {
                const existing = studentMap.get(student.id);

                if (existing) {
                    existing.attendanceCount += 1;
                } else {
                    studentMap.set(student.id, {
                        studentId: student.id,
                        name: student.user.name,
                        attendanceCount: 1
                    });
                }
            });
        });

        const result = Array.from(studentMap.values());

        return res.status(200).json({
            stats: result
        });

    } catch (e) {
        console.error("❌ getAttendanceStatsByClass", e);
        return res.status(500).json({ message: "Failed to get attendance stats" });
    }
};