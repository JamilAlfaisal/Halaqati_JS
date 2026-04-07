import { Request, Response } from 'express';
import { AppDataSource } from '../data-source';
import { User } from '../model/User';
import { Student } from '../model/Student';
import { Class } from '../model/Class';
import { Event } from '../model/Events';
import { AuthRequest } from '../middleware/middleware';
import { StudyIn } from '../model/Study_in';
import { In } from 'typeorm';
import { HaveAssignment } from '../model/Have_assignment';
export const createEvent = async (req: AuthRequest, res: Response) => {

    const classRepository = AppDataSource.getRepository(Class);
    const eventRepository = AppDataSource.getRepository(Event);

    try {
        const userId = req.user?.id;
        const role = req.user?.role;
        const classId = Number(req.params.id);
        console.log(classId);
        if (!userId) {
            console.log("❌ http://localhost:3000/api/event/create");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if (role != "teacher") {
            console.log("❌ http://localhost:3000/api/event/create");
            return res.status(403).json({ message: "Forbidden" })
        }

        if (isNaN(classId)) {
            console.log("❌ http://localhost:3000/api/event/create");
            return res.status(400).json({ message: "Invalid class id" });
        }

        const existingClass = await classRepository.findOne({
            where: {
                id: classId,
                teacher: { id: userId }
            }
        });

        if (!existingClass) {
            console.log("❌ http://localhost:3000/api/event/create");
            return res.status(403).json({ message: "Access denied or class not found" });
        }

        const { dueDate, description, title } = req.body
        console.log("dueDate: ", dueDate);

        if (!title || !dueDate || !description) {
            console.log("❌ http://localhost:3000/api/event/create");
            return res.status(400).json({ message: "Missing required fields" });
        }

        const newEvent = eventRepository.create({
            title, description, dueDate, class: { id: classId }, teacher: { id: userId }
        });

        await eventRepository.save(newEvent);

        console.log("✅ http://localhost:3000/api/event/create");
        return res.status(201).json({
            id: newEvent.id,
            title: newEvent.title,
            dueDate: newEvent.dueDate,
            description: newEvent.description,
            classId
        });

    } catch (e) {
        console.log("❌ http://localhost:3000/api/event/create");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to create event" });
    }

}

export const updateEvent = async (req: AuthRequest, res: Response) => {

    const eventRepository = AppDataSource.getRepository(Event);

    try {

        const userId = req.user?.id;
        const role = req.user?.role;
        const eventId = Number(req.params.id);

        if (!userId) {
            console.log("❌ http://localhost:3000/api/event/update");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if (role != "teacher") {
            console.log("❌ http://localhost:3000/api/event/update");
            return res.status(403).json({ message: "Forbidden" })
        }

        if (isNaN(eventId)) {
            console.log("❌ http://localhost:3000/api/event/update");
            return res.status(400).json({ message: "Invalid event id" });
        }

        const { dueDate, description, title } = req.body;

        if (
            title === undefined &&
            description === undefined &&
            dueDate === undefined
        ) {
            return res.status(400).json({ message: "No fields to update" });
        }

        const event = await eventRepository.findOne({
            where: { id: eventId },
            relations: ['teacher', 'class']
        });

        if (!event) {
            console.log("❌ http://localhost:3000/api/event/update");
            return res.status(404).json({ message: "Event not found" })
        }

        if (event.teacher.id !== userId) {
            console.log("❌ http://localhost:3000/api/event/update");
            return res.status(403).json({ message: "Forbidden" })
        }



        if (title !== undefined) event.title = title;
        if (description !== undefined) event.description = description;
        if (dueDate !== undefined) event.dueDate = dueDate;

        await eventRepository.save(event);

        console.log("✅ http://localhost:3000/api/event/update");
        return res.status(200).json({
            id: event.id,
            title: event.title,
            dueDate: event.dueDate,
            description: event.description,
            classId: event.class.id
        });

    } catch (e) {
        console.log("❌ http://localhost:3000/api/event/update");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to update event" });
    }
}

export const deleteEvent = async (req: AuthRequest, res: Response) => {

    const eventRepository = AppDataSource.getRepository(Event);

    try {
        const userId = req.user?.id;
        const role = req.user?.role;
        const eventId = Number(req.params.id);
        if (!userId) {
            console.log("❌ http://localhost:3000/api/event/delete");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if (role != "teacher") {
            console.log("❌ http://localhost:3000/api/event/delete");
            return res.status(403).json({ message: "Forbidden" })
        }

        if (isNaN(eventId)) {
            return res.status(400).json({ message: "Invalid event id" });
        }

        const event = await eventRepository.findOne({
            where: { id: eventId },
            relations: ["teacher"],
        });

        if (!event) {
            console.log("❌ http://localhost:3000/api/event/delete");
            return res.status(404).json({ message: "Event not found" });
        }

        if (event.teacher.id != userId) {
            console.log("❌ http://localhost:3000/api/event/delete");
            return res.status(403).json({ message: "Not event owner" });
        }

        await eventRepository.delete(eventId);

        console.log("✅ http://localhost:3000/api/event/delete");
        return res.status(204).send();

    } catch (e) {
        console.log("❌ http://localhost:3000/api/event/delete");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to delete event" });
    }
}


export const getEventDetails = async (req: AuthRequest, res: Response) => {
    const classRepository = AppDataSource.getRepository(Class);
    const eventRepository = AppDataSource.getRepository(Event);
    try {
        const userId = req.user?.id;
        const role = req.user?.role;
        const eventId = Number(req.params.id);
        if (!userId) {
            console.log("❌ http://localhost:3000/api/event/details");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if (isNaN(eventId)) {
            return res.status(400).json({ message: "Invalid event id" });
        }


        const event = await eventRepository.findOne({
            where: { id: eventId },
            relations: ['class', 'teacher']
        });

        if (!event) {
            console.log("❌ http://localhost:3000/api/event/details");
            return res.status(404).json({ message: 'event not found' })
        }

        if (role === 'teacher') {
            if (event.teacher.id !== userId) {
                return res.status(403).json({ message: "Forbidden" });
            }
        }

        if (role === 'student') {
            const isEnrolled = await classRepository.exist({
                where: {
                    id: event.class.id,
                    studyInRecords: { student: { id: userId } },
                },
            });

            if (!isEnrolled) {
                return res.status(403).json({ message: "Forbidden" });
            }
        }
        console.log("✅ http://localhost:3000/api/event/details");
        return res.status(200).send({
            id: event.id,
            title: event.title,
            dueDate: event.dueDate,
            description: event.description,
            class: {
                id: event.class.id,
                name: event.class.name
            },
            teacher: {
                id: event.teacher.id,
                name: event.teacher.name
            }
        });

    } catch (e) {
        console.log("❌ http://localhost:3000/api/event/details");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to get the event details" });
    }
}

export const getTeacherEvents = async (req: AuthRequest, res: Response) => {
    const eventRepository = AppDataSource.getRepository(Event);
    const classRepository = AppDataSource.getRepository(Class);
    try {
        const userId = req.user.id;
        const role = req.user.role;
        const classId = Number(req.params.id);

        const offset = parseInt(req.query.offset as string) || 0;
        const limit = parseInt(req.query.limit as string) || 10;

        if (!userId) {
            console.log("❌ http://localhost:3000/api/event/get_teacher_events");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if (role != "teacher") {
            console.log("❌ http://localhost:3000/api/event/get_teacher_events");
            return res.status(403).json({ message: "Forbidden" })
        }

        if (isNaN(classId)) {
            console.log("❌ http://localhost:3000/api/event/get_teacher_events");
            return res.status(400).json({ message: "Invalid class id" });
        }

        const ownsClass = await classRepository.exist({
            where: {
                id: classId,
                teacher: { id: userId },
            },
        });

        if (!ownsClass) {
            console.log("❌ http://localhost:3000/api/event/get_teacher_events");
            return res.status(403).json({ message: "You do not own this class" });
        }

        const [events, total] = await eventRepository.findAndCount({
            where: { teacher: { id: userId }, class: { id: classId } },
            relations: ['class', 'teacher'],
            order: { createdAt: "DESC" },
            skip: offset,
            take: limit,
        });

        const eventsConsistantData = events.map((event) => {
            return {
                id: event.id,
                title: event.title,
                dueDate: event.dueDate,
                description: event.description,
                createdAt: event.createdAt,
                class: {
                    id: event.class.id,
                    name: event.class.name
                },
                teacher: {
                    id: event.teacher.id,
                    name: event.teacher.name
                }
            }
        })

        console.log("✅ http://localhost:3000/api/event/get_teacher_events");
        return res.status(200).send({
            events: eventsConsistantData,
            offset: offset,
            limit: limit,
            total: total
        });

    } catch (e) {
        console.log("❌ http://localhost:3000/api/event/get_teacher_events");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to get events" });
    }
}

export const getStudentEvents = async (req: AuthRequest, res: Response) => {
    const eventRepository = AppDataSource.getRepository(Event);
    const studyInRepository = AppDataSource.getRepository(StudyIn);
    const studentRepository = AppDataSource.getRepository(Student)
    try {
        const userId = req.user.id;
        const role = req.user.role;

        if (!userId) {
            console.log("❌ http://localhost:3000/api/event/get_student_events");
            return res.status(401).json({ message: "Unauthorized" });
        }

        if (role != "student") {
            console.log("❌ http://localhost:3000/api/event/get_student_events");
            return res.status(403).json({ message: "Forbidden" })
        }

        const student = await studentRepository.findOneBy({
            user: { id: userId }
        });

        if (!student) {
            console.log("❌ http://localhost:3000/api/event/get_student_events");
            return res.status(404).json({ message: "Student profile not found" });
        }

        const studyInClasses = await studyInRepository.find({
            where: {
                student: { id: student.id },
            },
            relations: ['class']
        });

        const classIds = studyInClasses.map(s => s.class.id);

        if (classIds.length === 0) {
            console.log("✅ http://localhost:3000/api/event/get_student_events");
            return res.status(200).json({ events: [] });
        }

        const events = await eventRepository.find({
            where: { class: { id: In(classIds) } },
            relations: ['class', 'teacher']
        });

        const eventsConsistantData = events.map((event) => {
            return {
                id: event.id,
                title: event.title,
                createdAt: event.createdAt,
                dueDate: event.dueDate,
                description: event.description,
                class: {
                    id: event.class.id,
                    name: event.class.name
                },
                teacher: {
                    id: event.teacher.id,
                    name: event.teacher.name
                }
            }
        })

        console.log("✅ http://localhost:3000/api/event/get_student_events");
        return res.status(200).send({
            events: eventsConsistantData
        });

    } catch (e) {
        console.log("❌ http://localhost:3000/api/event/get_student_events");
        console.error(`❌ ${e}`);
        return res.status(500).json({ message: "Failed to get events" });
    }
}

export const getStudentFeed = async (req: AuthRequest, res: Response) => {
    const haveAssignmentRepository = AppDataSource.getRepository(HaveAssignment);
    const eventRepository = AppDataSource.getRepository(Event);
    const studyInRepository = AppDataSource.getRepository(StudyIn);
    const studentRepository = AppDataSource.getRepository(Student);

    console.log("getStudentFeed has been called");

    try {
        const userId = req.user.id;
        const role = req.user.role;

        const offset = parseInt(req.query.offset as string) || 0;
        const limit = parseInt(req.query.limit as string) || 10;

        if (!userId) return res.status(401).json({ message: "Unauthorized" });
        if (role !== "student") return res.status(403).json({ message: "Forbidden" });

        const student = await studentRepository.findOneBy({
            user: { id: userId }
        });

        if (!student) {
            return res.status(404).json({ message: "Student profile not found" });
        }

        // 🔹 Assignments
        const haveAssignment = await haveAssignmentRepository.find({
            where: { student: { id: student.id } },
            relations: ['assignment', 'assignment.teacher', 'assignment.class']
        });

        const assignments = haveAssignment.map((ass) => ({
            type: "assignment",
            createdAt: ass.assignment.createdAt,
            data: {
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
                haveAssignment:
                    [
                        {
                            isComplete: ass.isComplete,
                            isRead: ass.isRead
                        }
                    ]
            }
        }));

        // 🔹 Events
        const studyInClasses = await studyInRepository.find({
            where: { student: { id: student.id } },
            relations: ['class']
        });

        const classIds = studyInClasses.map(s => s.class.id);

        const eventsRaw = await eventRepository.find({
            where: { class: { id: In(classIds) } },
            relations: ['class', 'teacher']
        });

        const events = eventsRaw.map((event) => ({
            type: "event",
            createdAt: event.createdAt,
            data: {
                id: event.id,
                title: event.title,
                createdAt: event.createdAt,
                dueDate: event.dueDate,
                description: event.description,
                class: {
                    id: event.class.id,
                    name: event.class.name
                },
                teacher: {
                    id: event.teacher.id,
                    name: event.teacher.name
                }
            }
        }));

        // 🔥 Merge + Sort
        const combined = [...assignments, ...events];

        combined.sort((a, b) =>
            new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
        );

        // 🔥 Pagination
        const paginated = combined.slice(offset, offset + limit);

        return res.status(200).json({
            total: combined.length,
            offset,
            limit,
            feed: paginated
        });

    } catch (e) {
        console.error(e);
        return res.status(500).json({ message: "Failed to get feed" });
    }
};