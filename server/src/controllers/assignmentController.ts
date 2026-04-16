import { Request, Response } from 'express';
import { AppDataSource } from '../data-source';
import { User } from '../model/User';
import { Student } from '../model/Student';
import { Class } from '../model/Class';
import { Assignment } from '../model/Assignment';
import { AuthRequest } from '../middleware/middleware';
import { HaveAssignment } from '../model/Have_assignment';
import { In } from "typeorm";
import { StudyIn } from '../model/Study_in';
import { Event } from '../model/Events';
import { sendNotification } from '../utils/notificationHelper';
import * as admin from 'firebase-admin';

export const createAssignment = async (req: AuthRequest, res: Response) => {

    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    const userRepository = queryRunner.manager.getRepository(User);
    const classRepository = queryRunner.manager.getRepository(Class);
    const assignmentRepository = queryRunner.manager.getRepository(Assignment);
    const haveAssignmentRepository = queryRunner.manager.getRepository(HaveAssignment);

    try {
        const userId = req.user?.id;
        const role = req.user?.role;
        const classId = Number(req.params?.id);

        if (!userId) {
            console.log("❌ http://localhost:3000/api/assignment/create");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if (role != "teacher") {
            console.log("❌ http://localhost:3000/api/assignment/create");
            return res.status(403).json({ message: "Forbidden" })
        }

        if (isNaN(classId)) {
            console.log("❌ http://localhost:3000/api/assignment/update");
            return res.status(400).json({ message: "Invalid class id" });
        }

        const existingClass = await classRepository.findOne({
            where: { id: classId },
            relations: ['teacher', 'studyInRecords', 'studyInRecords.student', 'studyInRecords.student.user']
        });


        if (!existingClass) {
            console.log("❌ http://localhost:3000/api/assignment/create");
            return res.status(404).json({ message: "Class not found" });
        }

        if (existingClass.teacher.id !== userId) {
            console.log("❌ http://localhost:3000/api/assignment/create");
            return res.status(403).json({ message: "Not allowed to manage this class" });
        }


        const { dueDate, description, pages, title, type, studentsIds } = req.body

        if (!Array.isArray(pages)) {
            return res.status(400).json({ message: "Missing pages field" });
        }

        if (dueDate && isNaN(Date.parse(dueDate))) {
            return res.status(400).json({ message: "Invalid due date" });
        }


        if (!title || !description) {
            console.log("❌ http://localhost:3000/api/assignment/create");
            return res.status(400).json({ message: "Missing Required Fields" })
        }

        if (!Array.isArray(studentsIds) || studentsIds.length === 0) {
            console.log("❌ http://localhost:3000/api/assignment/create");
            return res.status(400).json({ message: "students must be an array, and contains at least one student" });
        }

        const allStudentsBelongToClass = studentsIds.every((student) => {
            return existingClass?.studyInRecords.some((record) => {
                return record.student.user.id === parseInt(student)
            });
        });

        if (!allStudentsBelongToClass) {
            console.log("❌ http://localhost:3000/api/assignment/create");
            return res.status(403).json({ message: "One or more students do not belong to this class" });
        }

        const teacher = await userRepository.findOneBy({ id: userId });

        if (!teacher) {
            console.log("❌ http://localhost:3000/api/assignment/create");
            return res.status(404).json({ message: "User not found" })
        }

        const assignment = assignmentRepository.create({
            dueDate,
            description,
            pages,
            title,
            type,
            class: existingClass,
            teacher
        });

        await queryRunner.manager.save(assignment);


        const allHaveAssignments = studentsIds.map((id) => {
            return haveAssignmentRepository.create({
                assignment,
                student: { id }
            });
        });

        console.log(allHaveAssignments.map((ass) => ass.student.id));

        await queryRunner.manager.save(allHaveAssignments);

        const studentTokens = existingClass.studyInRecords
            .filter(record => studentsIds.includes(record.student.user.id.toString()))
            .map(record => record.student.user.fcmToken)
            .filter(Boolean);

        await sendNotification({
            tokens: studentTokens as string[],
            title: existingClass.name,
            body: assignment.title,
            data: {
                assignmentId: assignment.id.toString(),
                classId: classId.toString(),
                type: "assignment",
            },
        });

        await queryRunner.commitTransaction();

        console.log("✅ http://localhost:3000/api/assignment/create");
        return res.status(201).json({
            id: assignment.id,
            title: assignment.title,
            description: assignment.description,
            studentsIds: allHaveAssignments.map((ass) => ass.student.id),
            createdAt: assignment.createdAt,
            dueDate: assignment.dueDate,
            type: assignment.type,
            pages: assignment.pages,
            classId: classId,
        });
    } catch (e) {
        await queryRunner.rollbackTransaction();
        console.log("❌ http://localhost:3000/api/class/create");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to create assignment" });
    } finally {
        await queryRunner.release();
    }
}

export const updateAssignment = async (req: AuthRequest, res: Response) => {
    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    const classRepository = queryRunner.manager.getRepository(Class);
    const assignmentRepository = queryRunner.manager.getRepository(Assignment);
    const haveAssignmentRepository = queryRunner.manager.getRepository(HaveAssignment);

    try {

        const userId = req.user?.id;
        const role = req.user?.role;
        const assignmentId = Number(req.params.id);

        if (!userId) {
            console.log("❌ http://localhost:3000/api/assignment/update");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if (role != "teacher") {
            console.log("❌ http://localhost:3000/api/assignment/update");
            return res.status(403).json({ message: "Forbidden" })
        }

        if (isNaN(assignmentId)) {
            console.log("❌ http://localhost:3000/api/assignment/update");
            return res.status(400).json({ message: "Invalid assignment id" });
        }

        const { dueDate, description, pages, title, type, studentsIds } = req.body

        const existingAssignment = await assignmentRepository.findOne({
            where: { id: assignmentId },
            relations: ["teacher", "class", "haveAssignment", "haveAssignment.student"],
        });

        if (!existingAssignment) {
            console.log("❌ http://localhost:3000/api/assignment/update");
            return res.status(404).json({ message: "assignment not found" });
        }

        if (existingAssignment.teacher.id != userId) {
            console.log("❌ http://localhost:3000/api/assignment/update");
            return res.status(403).json({ message: "Not assignment owner" });
        }

        if (!Array.isArray(studentsIds) || studentsIds.length === 0) {
            console.log("❌ http://localhost:3000/api/assignment/update");
            return res.status(400).json({ message: "students must be an array, and contains at least one student" });
        }

        const existingClass = await classRepository.findOne({
            where: { id: existingAssignment.class.id },
            relations: ['studyInRecords', 'studyInRecords.student']
        });

        const allStudentsBelongToClass = studentsIds.every((student) => {
            return existingClass?.studyInRecords.some((record) => {
                return record.student.id === student
            });
        });

        if (!allStudentsBelongToClass) {
            console.log("❌ http://localhost:3000/api/assignment/update");
            return res.status(403).json({ message: "One or more students do not belong to this class" });
        }

        const existingStudentIds = existingAssignment.haveAssignment.map(s => s.student.id);

        const toAdd = studentsIds.filter(s => !existingStudentIds.includes(s));
        const toRemove = existingStudentIds.filter(s => !studentsIds.includes(s));

        await haveAssignmentRepository.delete({ student: { id: In(toRemove) }, assignment: { id: assignmentId } });
        const allHaveAssignments = toAdd.map((id) => {
            return haveAssignmentRepository.create({
                assignment: existingAssignment,
                student: { id }
            });
        });

        if (title !== undefined) existingAssignment.title = title;
        if (description !== undefined) existingAssignment.description = description;
        if (pages !== undefined) existingAssignment.pages = pages;
        if (dueDate !== undefined) existingAssignment.dueDate = dueDate;
        if (type !== undefined) existingAssignment.type = type;


        await queryRunner.manager.save(existingAssignment);
        await queryRunner.manager.save(allHaveAssignments);
        await queryRunner.commitTransaction();

        const allStudentsBelongToAssignment = existingAssignment.haveAssignment;

        console.log("✅ http://localhost:3000/api/assignment/update");
        return res.status(200).json({
            id: existingAssignment.id,
            title: existingAssignment.title,
            description: existingAssignment.description,
            students: studentsIds.map((a) => a),
            createdAt: existingAssignment.createdAt,
            dueDate: existingAssignment.dueDate,
            type: existingAssignment.type,
            pages: existingAssignment.pages,
            classId: existingAssignment.class.id,
        });

    } catch (e) {
        await queryRunner.rollbackTransaction();
        console.log("❌ http://localhost:3000/api/assignment/update");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to update assignment" });
    } finally {
        await queryRunner.release();
    }
}

export const deleteAssignment = async (req: AuthRequest, res: Response) => {
    const assignmentRepository = AppDataSource.getRepository(Assignment);

    try {
        const userId = req.user?.id;
        const role = req.user?.role;
        const assignmentId = Number(req.params.id);
        if (!userId) {
            console.log("❌ http://localhost:3000/api/assignment/delete");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if (role != "teacher") {
            console.log("❌ http://localhost:3000/api/assignment/delete");
            return res.status(403).json({ message: "Forbidden" })
        }

        if (isNaN(assignmentId)) {
            console.log("❌ http://localhost:3000/api/assignment/delete");
            return res.status(400).json({ message: "Invalid assignment id" });
        }

        const existingAssignment = await assignmentRepository.findOne({
            where: { id: assignmentId },
            relations: ['teacher']
        });

        if (!existingAssignment) {
            console.log("✅ http://localhost:3000/api/assignment/delete");
            return res.status(204).send();
        }

        if (userId !== existingAssignment.teacher.id) {
            console.log("❌ http://localhost:3000/api/assignment/delete");
            return res.status(403).json({ message: "Forbidden" })
        }

        await assignmentRepository.delete(assignmentId);

        console.log("✅ http://localhost:3000/api/assignment/delete");
        return res.status(204).send();

    } catch (e) {
        console.log("❌ http://localhost:3000/api/assignment/delete");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to delete assignment" });
    }
}

export const getTeacherAssignments = async (req: AuthRequest, res: Response) => {

    const assignmentRepository = AppDataSource.getRepository(Assignment);
    try {
        const userId = req.user?.id;
        const role = req.user?.role;
        if (!userId) {
            console.log("❌ http://localhost:3000/api/assignment/get");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if (role != "teacher") {
            console.log("❌ http://localhost:3000/api/assignment/get");
            return res.status(403).json({ message: "Forbidden" })
        }

        const allAssignments = await assignmentRepository
            .createQueryBuilder('assignment')
            .leftJoinAndSelect('assignment.class', 'class')
            .leftJoinAndSelect('assignment.haveAssignment', 'haveAssignment')
            .leftJoinAndSelect('haveAssignment.student', 'student')
            .where('assignment.teacherId = :teacherId', { teacherId: userId })
            .orderBy('assignment.createdAt', 'DESC')
            .getMany();

        console.log("✅ http://localhost:3000/api/assignment/get");
        return res.status(200).send({
            assignments: allAssignments.map((record) => {
                return {
                    id: record.id,
                    title: record.title,
                    description: record.description,
                    students: record.haveAssignment.map(ass => ({
                        id: ass.student.id,
                        isComplete: ass.isComplete,
                        isRead: ass.isRead,
                    })),
                    createdAt: record.createdAt,
                    dueDate: record.dueDate,
                    type: record.type,
                    pages: record.pages,
                    classId: record.class.id,
                }
            })
        });
    } catch (e) {
        console.log("❌ http://localhost:3000/api/assignment/get");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to get your assignments" });
    }
}

export const getAssignmentDetails = async (req: AuthRequest, res: Response) => {
    const assignmentRepository = AppDataSource.getRepository(Assignment);
    const haveAssignmentRepository = AppDataSource.getRepository(HaveAssignment);
    try {
        const userId = req.user?.id;
        const role = req.user?.role;
        const assignmentId = Number(req.params.id);
        if (!userId) {
            console.log("❌ http://localhost:3000/api/assignment/details");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if (isNaN(assignmentId)) {
            console.log("❌ http://localhost:3000/api/assignment/details");
            return res.status(400).json({ message: "Invalid assignment id" });
        }

        const assignment = await assignmentRepository.findOne({
            where: { id: assignmentId },
            relations: ['teacher', 'haveAssignment', 'class', 'haveAssignment.student']
        });

        if (!assignment) {
            console.log("❌ http://localhost:3000/api/assignment/details");
            return res.status(404).json({ message: 'assignment not found' })
        }

        if (role === "teacher") {
            if (assignment.teacher.id !== userId) {
                return res.status(403).json({ message: "Forbidden" });
            }
            console.log("✅ http://localhost:3000/api/assignment/details");
            return res.status(200).json({
                id: assignment.id,
                title: assignment.title,
                description: assignment.description,
                students: assignment.haveAssignment.map(ha => ({
                    id: ha.student.id,
                    isComplete: ha.isComplete,
                    isRead: ha.isRead,
                })),
                createdAt: assignment.createdAt,
                dueDate: assignment.dueDate,
                type: assignment.type,
                pages: assignment.pages,
                classId: assignment.class.id,
            });
        }

        if (role === "student") {
            const haveAssignment = await haveAssignmentRepository.findOne({
                where: {
                    assignment: { id: assignmentId },
                    student: { id: userId },
                },
            });

            if (!haveAssignment) {
                return res.status(403).json({ message: "Forbidden" });
            }
            console.log("✅ http://localhost:3000/api/assignment/details");
            return res.status(200).json({
                id: assignment.id,
                title: assignment.title,
                description: assignment.description,
                createdAt: assignment.createdAt,
                dueDate: assignment.dueDate,
                type: assignment.type,
                pages: assignment.pages,
                classId: assignment.class.id,
                isComplete: haveAssignment.isComplete,
                isRead: haveAssignment.isRead
            });
        }
        console.log("❌ http://localhost:3000/api/assignment/details");
        return res.status(403).json({ message: "Forbidden" });
    } catch (e) {
        console.log("❌ http://localhost:3000/api/assignment/details");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to get the assignment details" });
    }
}

export const markAsCompleteUncomplete = async (req: AuthRequest, res: Response) => {
    const haveAssignmentRepository = AppDataSource.getRepository(HaveAssignment);
    const assignmentRepository = AppDataSource.getRepository(Assignment);

    try {
        const studentId = req?.user.id;
        const role = req?.user.role;
        const assignmentId = Number(req.params.id);

        if (!studentId) {
            console.log("❌ http://localhost:3000/api/assignment/mark_as_complete_uncomplete");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if (role != "student") {
            console.log("❌ http://localhost:3000/api/assignment/mark_as_complete_uncomplete");
            return res.status(403).json({ message: "Forbidden" })
        }

        if (isNaN(assignmentId)) {
            console.log("❌ http://localhost:3000/api/assignment/mark_as_complete_uncomplete");
            return res.status(400).json({ message: "Invalid assignment id" });
        }

        const haveAssignment = await haveAssignmentRepository.findOne({
            where: {
                assignment: { id: assignmentId },
                student: { id: studentId }
            },
            relations: ['assignment', 'assignment.class']
        });

        if (!haveAssignment) {
            return res.status(403).json({
                message: "Not assignment owner"
            })
        }

        haveAssignment.isComplete = !haveAssignment.isComplete;
        await haveAssignmentRepository.save(haveAssignment);

        console.log("✅ http://localhost:3000/api/assignment/mark_as_complete_uncomplete");
        return res.status(200).json({
            id: haveAssignment.assignment.id,
            title: haveAssignment.assignment.title,
            description: haveAssignment.assignment.description,
            isComplete: haveAssignment.isComplete,
            isRead: haveAssignment.isRead,
            createdAt: haveAssignment.assignment.createdAt,
            dueDate: haveAssignment.assignment.dueDate,
            type: haveAssignment.assignment.type,
            pages: haveAssignment.assignment.pages,
            classId: haveAssignment.assignment.class.id,
        });
    } catch (e) {
        console.log("❌ http://localhost:3000/api/assignment/mark_as_complete_uncomplete");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to change the assignment mark" });
    }
}

export const getStudentsAssignment = async (req: AuthRequest, res: Response) => {
    const haveAssignmentRepository = AppDataSource.getRepository(HaveAssignment);
    const studentRepository = AppDataSource.getRepository(Student);
    try {
        const userId = req?.user.id;
        const role = req?.user.role;

        if (!userId) {
            console.log("❌ http://localhost:3000/api/assignment/get_student_assignment");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if (role != "student") {
            console.log("❌ http://localhost:3000/api/assignment/get_student_assignment");
            return res.status(403).json({ message: "Forbidden" })
        }

        const student = await studentRepository.findOneBy({
            user: { id: userId }
        });

        if (!student) {
            console.log("❌ http://localhost:3000/api/event/get_student_assignment");
            return res.status(404).json({ message: "Student profile not found" });
        }

        const haveAssignment = await haveAssignmentRepository.find({
            where: { student: { id: student.id } },
            relations: ['assignment', 'assignment.teacher', 'assignment.class']
        });

        const assignments = haveAssignment
            .filter((ass) => ass.assignment) // 🔥 VERY IMPORTANT
            .map((ass) => {
                return {
                    teacher: {
                        id: ass.assignment.teacher.id,
                        name: ass.assignment.teacher.name,
                    },
                    class: {
                        id: ass.assignment.class.id,
                        name: ass.assignment.class.name
                    },
                    assignmentId: ass.assignment.id,
                    title: ass.assignment.title,
                    description: ass.assignment.description,
                    type: ass.assignment.type,
                    pages: ass.assignment.pages,
                    createdAt: ass.assignment.createdAt,
                    dueDate: ass.assignment.dueDate,
                    haveAssignment: [
                        {
                            isComplete: ass.isComplete,
                            isRead: ass.isRead
                        }
                    ]
                }
            });


        console.log("✅ http://localhost:3000/api/assignment/get_student_assignment");
        return res.status(200).json({
            assignments
        });
    } catch (e) {
        console.log("❌ http://localhost:3000/api/assignment/get_student_assignment");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to get the assignment" });
    }
}

export const getStudentAssignmentsByTeacher = async (req: AuthRequest, res: Response) => {
    const haveAssignmentRepository = AppDataSource.getRepository(HaveAssignment);
    const studentRepository = AppDataSource.getRepository(Student);

    try {
        const userId = req?.user.id;
        const role = req?.user.role;
        const classId = req.params.classId;
        const studentUserId = req.params.id;

        const offset = parseInt(req.query.offset as string) || 0;
        const limit = parseInt(req.query.limit as string) || 10;


        if (!userId) {
            return res.status(401).json({ message: "Unauthorized" });
        }

        // 2. Security Check: Only teachers can access this specific route
        if (role !== "teacher") {
            return res.status(403).json({ message: "Forbidden: Teachers only" });
        }

        if (!studentUserId) {
            return res.status(400).json({ message: "Student ID is required" });
        }


        // 3. Find student by their profile ID
        const student = await studentRepository.findOne({
            where: {
                user: {
                    id: parseInt(studentUserId),
                },
            },
            relations: ['haveAssignment', 'haveAssignment.assignment', 'haveAssignment.assignment.class']
        });

        if (!student) {
            return res.status(404).json({ message: "Student not found" });
        }

        // ✅ Filter first
        const filtered = student.haveAssignment.filter(
            (item) => item.assignment.class.id === parseInt(classId)
        );

        // ✅ Apply pagination
        const paginated = filtered.slice(offset, offset + limit);

        const properJson = paginated.map((item) => ({
            ...item.assignment,
            haveAssignment: [
                {
                    isComplete: item.isComplete,
                    isRead: item.isRead,
                    id: studentUserId,
                },
            ],
        }));

        return res.status(200).json({
            total: filtered.length,
            offset,
            limit,
            assignments: properJson
        });

    } catch (e) {
        console.error(`❌ Error fetching student assignments: ${e}`);
        return res.status(500).json({ message: "Internal server error" });
    }

}


export const markAssignmentAsRead = async (req: AuthRequest, res: Response) => {
    const haveAssignmentRepository = AppDataSource.getRepository(HaveAssignment);
    try {
        const studentId = req?.user.id;
        const role = req?.user.role;
        const assignmentId = Number(req.params.id);

        if (!studentId) {
            console.log("❌ http://localhost:3000/api/assignment/mark_as_read");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if (role !== "student") {
            console.log("❌ http://localhost:3000/api/assignment/mark_as_read");
            return res.status(403).json({ message: "Forbidden" });
        }

        if (isNaN(assignmentId)) {
            console.log("❌ http://localhost:3000/api/assignment/mark_as_read");
            return res.status(400).json({ message: "Invalid assignment id" });
        }

        const haveAssignment = await haveAssignmentRepository.findOne({
            where: {
                assignment: { id: assignmentId },
                student: { id: studentId }
            },
            relations: ['assignment', 'assignment.class']
        });

        if (!haveAssignment) {
            return res.status(403).json({
                message: "Not assignment owner"
            });
        }

        // // ✅ mark as read (no toggle)
        // haveAssignment.isRead = true;

        // await haveAssignmentRepository.save(haveAssignment);

        console.log("good it has been updated");
        await haveAssignmentRepository.update(
            { id: haveAssignment.id }, // ensure unique PK
            { isRead: true }
        );

        console.log("✅ http://localhost:3000/api/assignment/mark_as_read");
        return res.status(200).json({
            id: haveAssignment.assignment.id,
            title: haveAssignment.assignment.title,
            description: haveAssignment.assignment.description,
            isRead: haveAssignment.isRead,
            isComplete: haveAssignment.isComplete,
            createdAt: haveAssignment.assignment.createdAt,
            dueDate: haveAssignment.assignment.dueDate,
            type: haveAssignment.assignment.type,
            pages: haveAssignment.assignment.pages,
            classId: haveAssignment.assignment.class.id,
        });

    } catch (e) {
        console.log("❌ http://localhost:3000/api/assignment/mark_as_read");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to mark assignment as read" });
    }
};


export const getStudentStats = async (req: AuthRequest, res: Response) => {
    const haveAssignmentRepo = AppDataSource.getRepository(HaveAssignment);
    const studentRepo = AppDataSource.getRepository(Student);
    const eventRepo = AppDataSource.getRepository(Event);
    const studyInRepo = AppDataSource.getRepository(StudyIn);

    try {
        const userId = req.user?.id;
        const role = req.user?.role;

        if (!userId) {
            return res.status(401).json({ message: "Unauthorized" });
        }

        if (role !== "student") {
            return res.status(403).json({ message: "Forbidden" });
        }

        const student = await studentRepo.findOneBy({
            user: { id: userId }
        });

        if (!student) {
            return res.status(404).json({ message: "Student not found" });
        }

        // ✅ ALL COUNTS FROM DB (REAL-TIME)
        const totalAssignments = await haveAssignmentRepo.count({
            where: { student: { id: student.id } }
        });

        const readAssignments = await haveAssignmentRepo.count({
            where: {
                student: { id: student.id },
                isRead: true
            }
        });

        const completedAssignments = await haveAssignmentRepo.count({
            where: {
                student: { id: student.id },
                isComplete: true
            }
        });

        const notCompletedAssignments = await haveAssignmentRepo.count({
            where: {
                student: { id: student.id },
                isComplete: false
            }
        });

        const studyIn = await studyInRepo.find({
            where: { student: { id: student.id } },
            relations: ['class']
        });

        const classIds = studyIn.map(s => s.class.id);

        let totalEvents = 0;

        if (classIds.length > 0) {
            totalEvents = await eventRepo.count({
                where: {
                    class: {
                        id: In(classIds)
                    }
                }
            });
        }

        return res.status(200).json({
            stats: {
                totalAssignments,
                readAssignments,
                completedAssignments,
                notCompletedAssignments,
                totalEvents
            }
        });

    } catch (e) {
        console.error(e);
        return res.status(500).json({ message: "Failed to get stats" });
    }
};

