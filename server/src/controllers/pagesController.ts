import { Request, Response } from 'express';
import { AppDataSource } from '../data-source'; // Your TypeORM AppDataSource initialization
import { PageProgress } from '../model/pages';
import { Student } from '../model/Student';
import { AuthRequest } from '../middleware/middleware';

export class PagesController {

    public async updateMemorizedPage(req: AuthRequest, res: Response): Promise<Response> {
        const { studentId, pageNumber, classId } = req.body;
        const currentTeacherId = req.user?.id;
        const role = req.user?.role;

        if (!studentId || !pageNumber) {
            console.log("❌ http://localhost:3000/api/update_student/page");
            return res.status(400).json({ message: 'Student ID and Page Number are required.' });
        }

        if (role != "teacher") {
            console.log("❌ http://localhost:3000/api/update_student/page");
            return res.status(403).json({ message: "Forbidden" })
        }

        if (pageNumber < 1 || pageNumber > 604) {
            return res.status(400).json({ message: 'Invalid page number. Must be between 1 and 604.' });
        }

        if (!classId || classId == null) {
            return res.status(400).json({ message: 'Invalid class ID.' });
        }

        try {
            return await AppDataSource.transaction(async (transactionalEntityManager) => {

                // 2. Check if this page has already been logged by any teacher
                const existingProgress = await transactionalEntityManager.findOne(PageProgress, {
                    where: { studentId, pageNumber }
                });

                if (existingProgress) {
                    // Implementing the First-Claim rule: If locked by someone else, reject completely
                    if (existingProgress.teacherId !== currentTeacherId) {
                        return res.status(403).json({
                            message: 'Security Restriction: This page is locked. Only the original teacher can modify this record.'
                        });
                    }

                    // If the SAME teacher clicked it again, we return a gentle success indicating it's already recorded
                    return res.status(200).json({ message: 'Page is already marked as memorized by you.', data: existingProgress });
                }

                // 3. Page is empty! Create the new progress log and lock it to the current teacher
                const newProgress = new PageProgress();
                newProgress.studentId = studentId;
                newProgress.pageNumber = pageNumber;
                newProgress.classId = classId;
                newProgress.teacherId = currentTeacherId;
                newProgress.markingDate = new Date();
                newProgress.reviewDate = new Date();

                await transactionalEntityManager.save(PageProgress, newProgress);

                const currentJuz = PagesController.getJuzFromPage(pageNumber);
                const { startPage, endPage } = PagesController.getPageRangeForJuz(currentJuz);

                const completedPagesInJuzCount = await transactionalEntityManager.count(PageProgress, {
                    where: {
                        studentId,
                        pageNumber: require('typeorm').Between(startPage, endPage)
                    }
                });

                const totalPagesInThisJuz = (endPage - startPage) + 1;

                if (completedPagesInJuzCount === totalPagesInThisJuz) {
                    const student = await transactionalEntityManager.findOne(Student, { where: { id: studentId } });
                    if (student && !student.memorized_juz.includes(currentJuz.toString())) {
                        student.memorized_juz = [...student.memorized_juz, currentJuz.toString()];
                        await transactionalEntityManager.save(Student, student);
                    }
                }

                return res.status(201).json({
                    message: `Page ${pageNumber} marked as memorized successfully. Locked to your profile.`,
                    data: newProgress
                });
            });

        } catch (error) {
            console.error('Error logging page progress:', error);
            return res.status(500).json({ message: 'An internal server error occurred while processing progress updates.' });
        }
    }



    private static getJuzFromPage(page: number): number {
        if (page <= 21) return 1;
        return Math.min(Math.floor((page - 22) / 20) + 2, 30);
    }

    private static getPageRangeForJuz(juz: number): { startPage: number; endPage: number } {
        if (juz === 1) return { startPage: 1, endPage: 21 };
        const startPage = ((juz - 1) * 20) + 2;
        const endPage = startPage + 19;
        return { startPage, endPage: endPage > 604 ? 604 : endPage };
    }


    public async updateReviewDate(req: AuthRequest, res: Response): Promise<Response> {
        const { studentId, pageNumber, classId } = req.body;
        const currentTeacherId = req.user?.id;
        // const role = req.user?.role;

        if (!studentId || !pageNumber) {
            console.log("❌ http://localhost:3000/api/update_student/review_date");
            return res.status(400).json({ message: 'Student ID and Page Number are required.' });
        }

        // if (role !== "teacher") {
        //     console.log("❌ http://localhost:3000/api/update_student/review_date");
        //     return res.status(403).json({ message: "Forbidden" });
        // }

        if (!classId || classId == null) {
            return res.status(400).json({ message: 'Invalid class ID.' });
        }

        if (pageNumber < 1 || pageNumber > 604) {
            return res.status(400).json({ message: 'Invalid page number. Must be between 1 and 604.' });
        }

        try {
            const progressRecord = await AppDataSource.getRepository(PageProgress).findOne({
                where: { studentId, pageNumber }
            });

            if (!progressRecord) {
                return res.status(404).json({
                    message: 'This page has not been marked as memorized yet. You must record memorization before updating review status.'
                });
            }

            // if (progressRecord.teacherId !== currentTeacherId) {
            //     return res.status(403).json({
            //         message: 'Security Restriction: Only the original teacher who registered this page can modify its review date.'
            //     });
            // }

            progressRecord.reviewDate = new Date();
            await AppDataSource.getRepository(PageProgress).save(progressRecord);

            return res.status(200).json({
                message: `Review date for page ${pageNumber} updated successfully.`,
                data: progressRecord
            });

        } catch (error) {
            console.error('Error updating page review date:', error);
            return res.status(500).json({ message: 'An internal server error occurred while updating the review date.' });
        }
    }

    public async unselectMemorizedPage(req: AuthRequest, res: Response): Promise<Response> {
        const { studentId, pageNumber } = req.body;
        const currentTeacherId = req.user?.id;
        const role = req.user?.role;

        // 1. Validation
        if (!studentId || !pageNumber) {
            console.log("❌ http://localhost:3000/api/update_student/unselect_page");
            return res.status(400).json({ message: 'Student ID and Page Number are required.' });
        }

        if (role !== "teacher") {
            console.log("❌ http://localhost:3000/api/update_student/unselect_page");
            return res.status(403).json({ message: "Forbidden" });
        }

        try {
            return await AppDataSource.transaction(async (transactionalEntityManager) => {

                // 2. Fetch the existing record
                const existingProgress = await transactionalEntityManager.findOne(PageProgress, {
                    where: { studentId, pageNumber }
                });

                if (!existingProgress) {
                    return res.status(404).json({ message: 'This page is not marked as memorized.' });
                }

                // 3. Security Check: Enforce the First-Claim rule
                if (existingProgress.teacherId !== currentTeacherId) {
                    return res.status(403).json({
                        message: 'Security Restriction: Only the original teacher who marked this page can unselect it.'
                    });
                }

                // 4. Calculate the Juz before deleting the page
                const currentJuz = PagesController.getJuzFromPage(pageNumber);


                // 5. Delete the progress record
                await transactionalEntityManager.remove(PageProgress, existingProgress);

                // 6. Manage the student's completed Juz' array
                const student = await transactionalEntityManager.findOne(
                    Student, { where: { id: studentId } }
                );
                if (!student) {
                    return res.status(404).json({ message: "Student not found" });
                }

                // 2. SAFETY CHECK: Initialize the array if it's null/undefined

                if (!student.memorized_juz || student.memorized_juz === null || student.memorized_juz === undefined) {
                    student.memorized_juz = [];
                }

                // 3. Now your logic is safe
                const juzString = currentJuz.toString();

                console.log("🚀 ~ student.memorized_juz: before delete ", student.memorized_juz)
                if (student.memorized_juz.includes(juzString)) {
                    // filter() creates a new array reference, which is good
                    console.log("🚀 ~ student.memorized_juz:2 ", student.memorized_juz)
                    const updatedList = student.memorized_juz.filter(juz => juz.toString() !== juzString);

                    // Explicitly update the property
                    student.memorized_juz = updatedList;

                    console.log("🚀 ~ Removing Juz:", juzString);
                    console.log("🚀 ~ New List to be saved:", student.memorized_juz);

                    // Use the entity manager to save the specific student
                    await transactionalEntityManager.save(Student, student);
                }

                return res.status(200).json({
                    message: `Page ${pageNumber} has been unselected and is now open for tracking again.`
                });
            });

        } catch (error) {
            console.error('Error unselecting page progress:', error);
            return res.status(500).json({ message: 'An internal server error occurred while resetting page progress.' });
        }
    }

    public async getPagesByJuz(req: AuthRequest, res: Response): Promise<Response> {
        var { studentId, chapter } = req.body;
        const userId = req.user?.id;
        const role = req.user?.role;

        if (role == "student"){
            studentId = userId;
        }

        if (!studentId || !chapter) {
            console.log("❌ http://localhost:3000/api/pages/get-by-chapter - Missing Fields");
            return res.status(400).json({ message: 'Student ID and Chapter (Juz) number are required.' });
        }

        const juzNumber = Number(chapter);
        if (juzNumber < 1 || juzNumber > 30) {
            return res.status(400).json({ message: 'Invalid chapter. Quran Juz must be between 1 and 30.' });
        }

        try {
            // 2. Calculate the exact page boundaries for this Juz'
            const { startPage, endPage } = PagesController.getPageRangeForJuz(juzNumber);

            // 3. Query the database and eager-load the Teacher and Class details
            const memorizedPages = await AppDataSource.getRepository(PageProgress).find({
                where: {
                    studentId: studentId,
                    pageNumber: require('typeorm').Between(startPage, endPage)
                },
                relations: ['teacher', 'class'], // Automatically joins the teacher and class tables
                select: {
                    id: true,
                    pageNumber: true,
                    markingDate: true,
                    reviewDate: true,
                    teacherId: true,
                    // Selectively filter what sensitive teacher profile info goes to the frontend
                    teacher: {
                        id: true,
                        name: true,
                        email: true
                    },
                    class: {
                        id: true,
                        name: true,
                    }
                },
                order: {
                    pageNumber: 'ASC'
                }
            });

            // 4. Return packaged data
            return res.status(200).json({
                message: `Successfully retrieved progress data for Juz ${juzNumber} with instructor and class metadata.`,
                data: {
                    chapter: juzNumber,
                    startPage: startPage,
                    endPage: endPage,
                    totalPages: (endPage - startPage) + 1,
                    memorizedCount: memorizedPages.length,
                    memorizedPages: memorizedPages
                }
            });

        } catch (error) {
            console.error('Error fetching pages by chapter with relations:', error);
            return res.status(500).json({ message: 'An internal server error occurred while retrieving chapter details.' });
        }
    }

    // Admin: Get student list with Juz count for a class
    public async getAdminClassPageProgressSummary(req: AuthRequest, res: Response): Promise<Response> {
        const role = req.user?.role;
        if (role !== "admin") return res.status(403).json({ message: "Forbidden" });

        const classId = Number(req.params.classId);
        if (isNaN(classId)) return res.status(400).json({ message: "Invalid classId" });

        try {
            const rows = await AppDataSource.query(
                `SELECT 
                    s.id AS studentId,
                    u.name AS studentName,
                    s.memorized_juz AS memorizedJuzJson
                 FROM study_in si
                 INNER JOIN student s ON s.id = si.studentId
                 INNER JOIN user u ON u.id = s.id
                 WHERE si.classId = ?
                 ORDER BY u.name`,
                [classId]
            );

            const students = rows.map((r: any) => {
                let juzCount = 0;
                if (r.memorizedJuzJson && typeof r.memorizedJuzJson === 'string') {
                    const items = r.memorizedJuzJson.split(',').filter((x: string) => x.trim() !== '');
                    juzCount = items.length;
                }
                return {
                    studentId: r.studentId,
                    studentName: r.studentName,
                    juzCount
                };
            });

            return res.status(200).json({ classId, students });
        } catch (error) {
            console.error('Error fetching page progress summary:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }
    }

    // Admin: Get exact page progress rows for a specific student in a class (Lazy loaded)
    public async getAdminStudentPageProgress(req: AuthRequest, res: Response): Promise<Response> {
        const role = req.user?.role;
        if (role !== "admin") return res.status(403).json({ message: "Forbidden" });

        const classId = req.params.classId as string;
        const studentId = req.params.studentId as string;

        if (!studentId || !classId) return res.status(400).json({ message: "Missing params" });

        try {
            const progress = await AppDataSource.getRepository(PageProgress).find({
                where: { studentId: studentId, classId: classId },
                order: { pageNumber: "ASC" },
                select: ["pageNumber", "markingDate", "reviewDate"]
            });

            return res.status(200).json({ studentId, progress });
        } catch (error) {
            console.error('Error fetching student page progress:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }
    }

    // Admin: Get a global directory of all students with their juz count
    public async getAdminGlobalStudentDirectory(req: AuthRequest, res: Response): Promise<Response> {
        const role = req.user?.role;
        if (role !== "admin") return res.status(403).json({ message: "Forbidden" });

        try {
            const rows = await AppDataSource.query(
                `SELECT 
                    s.id AS studentId,
                    u.name AS studentName,
                    s.memorized_juz AS memorizedJuzJson,
                    GROUP_CONCAT(c.name SEPARATOR ', ') AS className
                 FROM student s
                 INNER JOIN user u ON u.id = s.id
                 LEFT JOIN study_in si ON si.studentId = s.id
                 LEFT JOIN class c ON c.id = si.classId
                 GROUP BY s.id, u.name, s.memorized_juz
                 ORDER BY u.name`
            );

            const students = rows.map((r: any) => {
                let juzCount = 0;
                if (r.memorizedJuzJson && typeof r.memorizedJuzJson === 'string') {
                    const items = r.memorizedJuzJson.split(',').filter((x: string) => x.trim() !== '');
                    juzCount = items.length;
                }
                return {
                    studentId: r.studentId,
                    studentName: r.studentName,
                    className: r.className || 'غير مسجل',
                    juzCount
                };
            });

            return res.status(200).json(students);
        } catch (error) {
            console.error('Error fetching global student directory:', error);
            return res.status(500).json({ message: 'Internal server error' });
        }
    }
}