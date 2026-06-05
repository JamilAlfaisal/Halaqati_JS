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
import { Grade } from '../model/Grade';


// function parseArabicDate(dateStr) {
//     // 1. Replace Arabic digits with Western digits
//     const westernDigits = dateStr.replace(/[٠-٩]/g, d => '٠١٢٣٤٥٦٧٨٩'.indexOf(d));

//     // 2. Try to parse the normalized string
//     return Date.parse(westernDigits);
// }

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
        console.log(dueDate);

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


//===============================================================
//  updateAssignment
//===============================================================

export const updateAssignment = async (req: AuthRequest, res: Response) => {
    const queryRunner = AppDataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    const classRepository = queryRunner.manager.getRepository(Class);
    const assignmentRepository = queryRunner.manager.getRepository(Assignment);
    const haveAssignmentRepository = queryRunner.manager.getRepository(HaveAssignment);
    const gradesRepository = queryRunner.manager.getRepository(Grade);

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

        // const existingAssignment = await assignmentRepository.findOne({
        //     where: { id: assignmentId },
        //     relations: ["teacher", "class", "haveAssignment", "haveAssignment.student.grades"],
        // });

        const existingAssignment = await assignmentRepository.createQueryBuilder("assignment")
            .leftJoinAndSelect("assignment.haveAssignment", "haveAssignment")
            .leftJoinAndSelect("assignment.teacher", "teacher")
            .leftJoinAndSelect("assignment.class", "class")
            .leftJoinAndSelect("haveAssignment.student", "student")
            .leftJoinAndSelect("student.user", "user")
            .leftJoinAndSelect("student.grades", "grades", "grades.assignment_id = :id", { id: assignmentId })
            .where("assignment.id = :id", { id: assignmentId })
            .getOne();

        console.log(existingAssignment?.haveAssignment[0].student.grades.length);
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
            relations: ['studyInRecords', 'studyInRecords.student.user']
        });

        if (!existingClass) {
            console.log("❌ http://localhost:3000/api/assignment/update");
            return res.status(403).json({ message: "Class not exist" });
        }

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
        console.log("1: ",toRemove)
        const restrictedRemoval = existingAssignment.haveAssignment.find(ha => 
            {
                return toRemove.includes(ha.student.id) && ha.student.grades.length > 0;
            }
        );

        if (restrictedRemoval) {
            throw new Error(`Cannot remove ${restrictedRemoval.student.user.name} because they already have a grade.`);
        }

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

        // const allStudentsBelongToAssignment = existingAssignment.haveAssignment;0

        const studentTokens = existingClass.studyInRecords
            .filter(record => toAdd.includes(record.student.id))
            .map(record => record.student.user.fcmToken)
            .filter(Boolean);
            
        console.log("studentTokens: ",studentTokens);
        await sendNotification({
            tokens: studentTokens as string[],
            title: existingClass.name,
            body: existingAssignment.title,
            data: {
                assignmentId: existingAssignment.id.toString(),
                classId: existingClass.id.toString(),
                type: "assignment",
            },
        });

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

//===============================================================
//  deleteAssignment
//===============================================================

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
        const { classId } = req.params;

        const page = parseInt(req.query.page as string) || 1;
        const limit = parseInt(req.query.limit as string) || 10;
        const skip = (page - 1) * limit;

        if (!userId) {
            console.log("❌ http://localhost:3000/api/assignment/get");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if (role != "teacher") {
            console.log("❌ http://localhost:3000/api/assignment/get");
            return res.status(403).json({ message: "Forbidden" })
        }

        const [allAssignments, totalCount] = await assignmentRepository
            .createQueryBuilder('assignment')
            .leftJoinAndSelect('assignment.class', 'class')
            .leftJoinAndSelect('assignment.haveAssignment', 'haveAssignment')
            .leftJoinAndSelect('haveAssignment.student', 'student')
            .leftJoinAndSelect(
                'student.grades',
                'grade',
                'grade.assignment_id = assignment.id'
            )
            .where('assignment.teacherId = :teacherId', { teacherId: userId })
            .andWhere('assignment.classId = :classId', { classId })
            .orderBy('assignment.createdAt', 'DESC')
            .skip(skip)   // Offset
            .take(limit)
            .getManyAndCount();

        console.log("✅ http://localhost:3000/api/assignment/get");
        return res.status(200).send({
            assignments: allAssignments.map((record) => {
                return {
                    id: record.id,
                    title: record.title,
                    description: record.description,
                    students: record.haveAssignment.map(ass => ({
                        id: ass.student.id,
                        grades: ass.student.grades,
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

        const assignment = await assignmentRepository.createQueryBuilder('assignment')
            .leftJoinAndSelect('assignment.teacher', 'teacher')
            .leftJoinAndSelect('assignment.class', 'class')
            .leftJoinAndSelect('assignment.haveAssignment', 'haveAssignment')
            .leftJoinAndSelect('haveAssignment.student', 'student')
            .leftJoinAndSelect('student.user', 'user')

            .leftJoinAndSelect(
                'student.grades',
                'grade',
                'grade.assignment_id = :assignmentId',
                { assignmentId }
            )
            .where('assignment.id = :assignmentId', { assignmentId })
            .getOne();

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
                    name: ha.student.user.name,
                    isComplete: ha.isComplete,
                    grade: ha.student.grades[0],
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

            const assignmentStudentVersion = await assignmentRepository.createQueryBuilder('assignment')
                .leftJoinAndSelect('assignment.teacher', 'teacher')
                .leftJoinAndSelect('assignment.class', 'class')
                .leftJoinAndSelect('assignment.haveAssignment', 'haveAssignment')
                .leftJoinAndSelect('haveAssignment.student', 'student')
                .leftJoinAndSelect('student.user', 'user')
                .leftJoinAndSelect(
                    'assignment.grades', 
                    'grade', 
                    'grade.student_id = :userId',
                    { userId }
                )
                .where('assignment.id = :assignmentId', { assignmentId })
                .getOne();

            if (!haveAssignment) {
                return res.status(403).json({ message: "Forbidden" });
            }
            console.log("wowwowowo")
            console.log("✅ http://localhost:3000/api/assignment/details");
            return res.status(200).json({
                id: assignment.id,
                title: assignment.title,
                description: assignment.description,
                createdAt: assignment.createdAt,
                dueDate: assignment.dueDate,
                type: assignment.type,
                pages: assignment.pages,
                isComplete: haveAssignment.isComplete,
                isRead: haveAssignment.isRead,
                grade: assignmentStudentVersion?.grades[0],
                class: {
                    id: assignment.class.id,
                    name: assignment.class.name
                },
                teacher: {
                    id: assignment.teacher.id,
                    name: assignment.teacher.name,
                    phone: assignment.teacher.phone,
                    email: assignment.teacher.email                    
                },
                haveAssignment: assignment.haveAssignment.map((record) => ({
                    isComplete: record.isComplete,
                    isRead: record.isRead,
                    ...record.student.user,
                    memorized_juz: record.student.memorized_juz,
                    grade: {...record?.student?.grades[0]}
                }))
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

        if (!classId) {
            return res.status(401).json({ message: "Class id is required" });
        }

        if (role !== "teacher") {
            return res.status(403).json({ message: "Forbidden: Teachers only" });
        }

        if (!studentUserId) {
            return res.status(400).json({ message: "Student ID is required" });
        }

        

        const studenttest = await studentRepository.createQueryBuilder('student')

            .leftJoinAndSelect('student.haveAssignment', 'haveAssignment')
            .leftJoinAndSelect('haveAssignment.assignment', 'assignment')
            .leftJoinAndSelect('assignment.class', 'class')
            .leftJoinAndSelect(
                'assignment.grades', 
                'grade', 
                'grade.student_id = student.id'
            )

            .where('student.id = :studentId', { studentId: parseInt(studentUserId.toString()) })
            .andWhere('class.id = :classId', { classId: parseInt(classId.toString()) })

            .orderBy('assignment.createdAt', 'DESC')
            .getOne();
            
        if (!studenttest) {
            return res.status(200).json({
                total: 0,
                offset,
                limit,
                assignments: []
            });
        }

        const properModel = studenttest?.haveAssignment.map((ha) => {
            return {
                id: ha.assignment.id,
                title: ha.assignment.title,
                description: ha.assignment.description,
                pages: ha.assignment.pages,
                type: ha.assignment.type,
                createdAt: ha.assignment.createdAt,
                dueDate: ha.assignment.dueDate,
                class: ha.assignment.class,
                haveAssignment: [{
                    id: studenttest.id,
                    isRead: ha.isRead,
                    isComplete: ha.isComplete,
                    grade: ha.assignment.grades.length > 0?ha.assignment.grades[0]:null
                }]
            }
        });


        const paginated = properModel.slice(offset, offset + limit);
        console.log("paginated: ",paginated);

        return res.status(200).json({
            total: paginated.length,
            offset,
            limit,
            assignments: paginated??[]
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

export const getAssignmentDetailsOfStudent = async (req: AuthRequest, res: Response) => {
    const assignmentRepository = AppDataSource.getRepository(Assignment);

    try {
        const teacherId = req.user?.id;
        const assignmentId = Number(req.params.id);
        const studentId = req.params.studentId; // UUID from student table

        if (!teacherId) return res.status(401).json({ message: "Unauthorized" });

        // Use QueryBuilder to filter the specific student and their specific grade
        const assignment = await assignmentRepository.createQueryBuilder('assignment')
            .leftJoinAndSelect('assignment.class', 'class')
            .leftJoinAndSelect('assignment.teacher', 'teacher')
            .leftJoinAndSelect('assignment.haveAssignment', 'haveAssignment')
            .leftJoinAndSelect('haveAssignment.student', 'student')
            // .leftJoinAndSelect('student.user', 'user',)
            // Filter the join so we only get the specific student requested
            .andWhere('student.id = :studentId', { studentId })
            // Join only the grade belonging to this specific assignment
            .leftJoinAndSelect(
                'student.grades',
                'grade',
                'grade.assignment_id = assignment.id'
            )
            .where('assignment.id = :assignmentId', { assignmentId })
            .getOne();

        if (!assignment) {
            return res.status(404).json({ message: 'Assignment or Student record not found' });
        }

        // Security check: Ensure this teacher owns the assignment
        if (assignment.teacher.id !== teacherId) {
            return res.status(403).json({ message: "Forbidden" });
        }

        // Since we filtered the QueryBuilder, haveAssignment[0] is our target student
        const ha = assignment.haveAssignment[0];

        return res.status(200).json({
            id: assignment.id,
            title: assignment.title,
            description: assignment.description,
            createdAt: assignment.createdAt,
            dueDate: assignment.dueDate,
            type: assignment.type,
            pages: assignment.pages,
            classId: assignment.class?.id,
            // The specific student data
            studentData: {
                id: ha.student.id,
                // name: ha.student.user.name,
                isComplete: ha.isComplete,
                isRead: ha.isRead,
                grade: ha.student.grades && ha.student.grades.length > 0
                    ? ha.student.grades[0]
                    : null
            }
        });

    } catch (e) {
        console.error(`❌ Error: ${e}`);
        return res.status(500).json({ message: "Internal Server Error" });
    }
};

