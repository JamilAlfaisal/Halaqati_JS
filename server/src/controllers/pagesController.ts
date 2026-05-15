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
                    if (student) {
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
        if (page === 1 || page === 2) return 1;
        return Math.ceil((page - 2) / 20);
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
                const student = await transactionalEntityManager.findOne(Student, { where: { id: studentId } });

                if (student && student.memorized_juz.includes(currentJuz.toString())) {
                    // Since a page was just removed, this Juz can no longer be marked as fully complete.
                    // We filter out this Juz from the student's list.
                    student.memorized_juz = student.memorized_juz.filter(juz => juz !== currentJuz.toString());
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
}