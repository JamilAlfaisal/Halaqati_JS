import { Response } from 'express';
import { AppDataSource } from '../data-source';
import { Grade } from '../model/Grade';
import { StudyIn } from '../model/Study_in';
import { Assignment } from '../model/Assignment';
import { AuthRequest } from '../middleware/middleware';
import { IsNull } from 'typeorm';

export class GradesController {
    public async setGrade(req: AuthRequest, res: Response): Promise<Response> {
        const { studentId, classId, assignmentId, score, weight, card, description } = req.body;
        const currentTeacherId = req.user?.id;
        const role = req.user?.role;

        if (role !== "teacher") {
            console.log("❌ http://localhost:3000/api/grades/set-grade - Unauthorized Role");
            return res.status(403).json({ message: "Forbidden: Only teachers can assign grades." });
        }

        if (!studentId || !classId || score === undefined || !weight) {
            console.log("❌ http://localhost:3000/api/grades/set-grade - Missing Fields");
            return res.status(400).json({ message: 'Missing required fields: studentId, classId, score, and weight are mandatory.' });
        }

        if (score < 0 || score > 20) {
            console.log("❌ http://localhost:3000/api/grades/set-grade - Invalid score");
            return res.status(400).json({ message: 'Invalid score. Grades must be capped strictly between 0 and 20.' });
        }

        if (![1, 2, 3].includes(Number(weight))) {
            console.log("❌ http://localhost:3000/api/grades/set-grade - Invalid weight");
            return res.status(400).json({ message: 'Invalid weight value. Weight must be 1, 2, or 3.' });
        }

        try {
            return await AppDataSource.transaction(async (transactionalEntityManager) => {

                if (assignmentId) {
                    const assignmentExists = await transactionalEntityManager
                        .createQueryBuilder(Assignment, 'assignment')
                        .innerJoin('assignment.haveAssignment', 'haveAssignment')
                        .innerJoin('haveAssignment.student', 'student', 'student.id = :studentId', { studentId })
                        // Left join the grades ONLY for this specific student
                        .leftJoin(
                            'assignment.grades', 
                            'grade', 
                            'grade.student_id = :studentId', 
                            { studentId }
                        )
                        .where('assignment.id = :assignmentId', { assignmentId })
                        .andWhere('grade.id IS NULL')
                        .getOne();
                    if (!assignmentExists) {
                        console.log("❌ http://localhost:3000/api/grades/set-grade - assignment template could not be found.");
                        return res.status(404).json({ message: 'The referenced assignment template could not be found.' });
                    }
                }

                const enrollment = await transactionalEntityManager.findOne(StudyIn, {
                    where: { student: { id: studentId }, class: { id: classId } }
                });
                if (!enrollment) {
                    console.log("❌ http://localhost:3000/api/grades/set-grade - Enrollment record not found");
                    return res.status(404).json({ message: 'Enrollment record not found. The student is not registered in this class.' });
                }

                const newGrade = new Grade();
                newGrade.score = Number(score);
                newGrade.weight = Number(weight);
                newGrade.card = (card !== undefined && card !== null) ? Number(card) : 0;
                newGrade.description = description || null;
                newGrade.student = studentId;
                newGrade.class = classId;
                newGrade.teacher = currentTeacherId;
                newGrade.dateTime = new Date();

                newGrade.assignment = assignmentId || null;

                await transactionalEntityManager.save(Grade, newGrade);

                const oldWeightPoints = Number(enrollment.totalWeightPoints);
                const oldCumulativeGrade = Number(enrollment.cumulativeGrade);

                const gradeWeight = Number(weight);
                const gradeScore = Number(score);

                const newWeightPoints = oldWeightPoints + gradeWeight;
                let newCumulativeGrade = 0;

                if (newWeightPoints > 0) {
                    const totalPreviousWeightedScores = oldCumulativeGrade * oldWeightPoints;
                    const newWeightedScoreContribution = gradeScore * gradeWeight;

                    newCumulativeGrade = (totalPreviousWeightedScores + newWeightedScoreContribution) / newWeightPoints;
                }

                enrollment.totalWeightPoints = newWeightPoints;
                enrollment.cumulativeGrade = Number(newCumulativeGrade.toFixed(2));

                await transactionalEntityManager.save(StudyIn, enrollment);
                console.log("✅ http://localhost:3000/api/grades/set-grade ");
                return res.status(201).json({
                    message: assignmentId
                        ? 'Grade recorded successfully against the assignment.'
                        : 'Ad-hoc grade recorded successfully.',
                    data: {
                        grade: newGrade,
                        updatedAverage: enrollment.cumulativeGrade,
                        updatedTotalWeightPoints: enrollment.totalWeightPoints
                    }
                });
            });

        } catch (error) {
            console.error('Error executing unified setGrade transaction block:', error);
            return res.status(500).json({ message: 'An internal server error occurred while calculating grades.' });
        }
    }


    public async updateGrade(req: AuthRequest, res: Response): Promise<Response> {
        const { gradeId, score: newScore, weight: newWeight, card: newCard, description, assignmentId } = req.body;
        const role = req.user?.role;

        // 1. Core Authorization Check
        if (role !== "teacher") {
            console.log("❌ http://localhost:3000/api/grades/update-grade - Unauthorized Role");
            return res.status(403).json({ message: "Forbidden: Only teachers can modify grades." });
        }

        // 2. Input Validation
        if (!gradeId || newScore === undefined || !newWeight) {
            console.log("❌ http://localhost:3000/api/grades/update-grade - Missing Fields");
            return res.status(400).json({ message: 'Missing required fields: gradeId, score, and weight are mandatory.' });
        }

        if (newScore < 0 || newScore > 20) {
            return res.status(400).json({ message: 'Invalid score. Grades must be capped strictly between 0 and 20.' });
        }

        if (![1, 2, 3].includes(Number(newWeight))) {
            return res.status(400).json({ message: 'Invalid weight value. Weight must be 1, 2, or 3.' });
        }

        try {
            return await AppDataSource.transaction(async (transactionalEntityManager) => {

                const oldGrade = await transactionalEntityManager.findOne(Grade, {
                    where: { id: gradeId },
                    relations: ['student', 'class']
                });

                if (!oldGrade) {
                    return res.status(404).json({ message: 'The specified grade record could not be found.' });
                }

                const studentId = typeof oldGrade.student === 'object' ? oldGrade.student.id : oldGrade.student;
                const classId = typeof oldGrade.class === 'object' ? oldGrade.class.id : oldGrade.class;

                const enrollment = await transactionalEntityManager.findOne(StudyIn, {
                    where: { student: { id: studentId }, class: { id: classId } }
                });

                if (!enrollment) {
                    return res.status(404).json({ message: 'Enrollment cache row not found for this student in this class.' });
                }

                if (assignmentId) {
                    const assignmentExists = await transactionalEntityManager.findOne(Assignment, {
                        where: { id: assignmentId }
                    });
                    if (!assignmentExists) {
                        return res.status(404).json({ message: 'The referenced assignment template could not be found.' });
                    }
                }

                const oldScoreVal = Number(oldGrade.score);
                const oldWeightVal = Number(oldGrade.weight);

                const currentTotalWeight = Number(enrollment.totalWeightPoints);
                const currentCumulativeGrade = Number(enrollment.cumulativeGrade);

                const finalWeightPoints = currentTotalWeight - oldWeightVal + Number(newWeight);
                let finalCumulativeGrade = 0;

                if (finalWeightPoints > 0) {

                    const previousTotalWeightedSum = currentCumulativeGrade * currentTotalWeight;
                    const adjustedWeightedSum = previousTotalWeightedSum - (oldScoreVal * oldWeightVal) + (Number(newScore) * Number(newWeight));

                    finalCumulativeGrade = adjustedWeightedSum / finalWeightPoints;
                }

                oldGrade.score = Number(newScore);
                oldGrade.weight = Number(newWeight);
                oldGrade.card = newCard !== undefined ? Number(newCard) : oldGrade.card;
                oldGrade.description = description !== undefined ? description : oldGrade.description;
                oldGrade.assignment = assignmentId !== undefined ? (assignmentId || null) : oldGrade.assignment;

                await transactionalEntityManager.save(Grade, oldGrade);
                enrollment.totalWeightPoints = finalWeightPoints;
                enrollment.cumulativeGrade = Number(finalCumulativeGrade.toFixed(2));

                await transactionalEntityManager.save(StudyIn, enrollment);

                return res.status(200).json({
                    message: 'Grade entry updated successfully and class analytics synced.',
                    data: {
                        updatedGrade: oldGrade,
                        updatedAverage: enrollment.cumulativeGrade,
                        updatedTotalWeightPoints: enrollment.totalWeightPoints
                    }
                });
            });

        } catch (error) {
            console.error('Error executing updateGrade transaction block:', error);
            return res.status(500).json({ message: 'An internal server error occurred while updating the grade analytics.' });
        }
    }

    public async deleteGrade(req: AuthRequest, res: Response): Promise<Response> {
        const { gradeId } = req.body; // or req.params.gradeId depending on your routes setup
        const role = req.user?.role;

        // 1. Core Authorization Check
        if (role !== "teacher") {
            console.log("❌ http://localhost:3000/api/grades/delete-grade - Unauthorized Role");
            return res.status(403).json({ message: "Forbidden: Only teachers can delete grades." });
        }

        // 2. Input Validation
        if (!gradeId) {
            console.log("❌ http://localhost:3000/api/grades/delete-grade - Missing gradeId");
            return res.status(400).json({ message: 'Grade ID is required to perform deletion.' });
        }

        try {
            return await AppDataSource.transaction(async (transactionalEntityManager) => {

                // 3. Find the targeted grade and load relations to find the cache row
                const gradeToDelete = await transactionalEntityManager.findOne(Grade, {
                    where: { id: gradeId },
                    relations: ['student', 'class']
                });

                if (!gradeToDelete) {
                    return res.status(404).json({ message: 'The specified grade record could not be found.' });
                }

                // Extract IDs from relations safely based on your schema setup
                const studentId = typeof gradeToDelete.student === 'object' ? gradeToDelete.student.id : gradeToDelete.student;
                const classId = typeof gradeToDelete.class === 'object' ? gradeToDelete.class.id : gradeToDelete.class;

                // 4. Locate the student's enrollment cache row
                const enrollment = await transactionalEntityManager.findOne(StudyIn, {
                    where: { student: { id: studentId }, class: { id: classId } }
                });

                if (!enrollment) {
                    return res.status(404).json({ message: 'Enrollment cache row not found for this student in this class.' });
                }

                // 5. Capture historical values before removing the grade record
                const oldScoreVal = Number(gradeToDelete.score);
                const oldWeightVal = Number(gradeToDelete.weight);

                const currentTotalWeight = Number(enrollment.totalWeightPoints);
                const currentCumulativeGrade = Number(enrollment.cumulativeGrade);

                // 6. Delete the physical Grade record from the database
                await transactionalEntityManager.remove(Grade, gradeToDelete);

                // 7. Recalculate the Math adjustments to the Enrollment Cache
                const finalWeightPoints = currentTotalWeight - oldWeightVal;
                let finalCumulativeGrade = 0;

                // Prevent Division by Zero if this was the last remaining grade in history
                if (finalWeightPoints > 0) {
                    const previousTotalWeightedSum = currentCumulativeGrade * currentTotalWeight;
                    const adjustedWeightedSum = previousTotalWeightedSum - (oldScoreVal * oldWeightVal);

                    finalCumulativeGrade = adjustedWeightedSum / finalWeightPoints;
                } else {
                    // Total weights are 0, meaning no history remains. Reset to base values.
                    finalCumulativeGrade = 0.00;
                }

                // 8. Persist updated mathematical caches down to the StudyIn row
                enrollment.totalWeightPoints = finalWeightPoints;
                enrollment.cumulativeGrade = Number(finalCumulativeGrade.toFixed(2));

                await transactionalEntityManager.save(StudyIn, enrollment);

                return res.status(200).json({
                    message: 'Grade entry deleted successfully and class analytics synced.',
                    data: {
                        updatedAverage: enrollment.cumulativeGrade,
                        updatedTotalWeightPoints: enrollment.totalWeightPoints
                    }
                });
            });

        } catch (error) {
            console.error('Error executing deleteGrade transaction block:', error);
            return res.status(500).json({ message: 'An internal server error occurred while deleting the grade record.' });
        }
    }

    public async getStudentGrades(req: AuthRequest, res: Response): Promise<Response> {
        var { studentId, classId } = req.params;

        const role = req.user?.role;
        const userId = req.user?.id;

        if (!studentId || !classId) {
            return res.status(400).json({ message: 'Student ID and Class ID are required parameters.' });
        }

        if(role == "student"){
            studentId = userId;
        }

        try {
            const summary = await AppDataSource.getRepository(StudyIn).findOne({
                where: { student: { id: Number(studentId) }, class: { id: Number(classId) } }
            });

            const offset = parseInt(req.query.offset as string) || 0;
            const limit = parseInt(req.query.limit as string) || 10;


            const [gradeHistory, totalCount] = await AppDataSource.getRepository(Grade).findAndCount({
                where: {
                    student: { id: Number(studentId) },
                    class: { id: Number(classId) }
                },
                relations: ['teacher', 'assignment'],
                select: {
                    id: true,
                    score: true,
                    weight: true,
                    card: role == "teacher",
                    description: role == "teacher",
                    dateTime: true,
                    teacher: {
                        id: true,
                        name: true,
                        email: true,
                        phone: true,
                        picProfile: true,
                    },
                    assignment: {
                        id: true,
                        title: true
                    }
                },
                order: {
                    dateTime: 'DESC'
                },
                skip: offset,
                take: limit
            });

            return res.status(200).json({
                message: "Grades retrieved successfully.",
                data: {
                    overallStats: {
                        cumulativeGrade: summary?.cumulativeGrade || 0,
                        dateOfregistration: summary?.registeredAt || 0,
                        totalWeightPoints: summary?.totalWeightPoints || 0
                    },
                    history: gradeHistory
                },
                meta: {
                    totalItems: totalCount,
                    currentPage: offset,
                    totalPages: Math.ceil(totalCount / limit),
                    itemsPerPage: limit
                }
            });

        } catch (error) {
            console.error('Error fetching student grades:', error);
            return res.status(500).json({ message: 'Internal server error while retrieving grade history.' });
        }
    }

    // Admin-only: get CGPA and card type counts per student within a date range
    public async getGradesStatsByDateRange(req: AuthRequest, res: Response): Promise<Response> {
        const role = req.user?.role;
        const userId = req.user?.id;

        if (!userId) return res.status(401).json({ message: "Unauthorized" });
        if (role !== "admin") return res.status(403).json({ message: "Forbidden" });

        const classId = Number(req.params.classId);
        const { startDate, endDate } = req.query;

        if (isNaN(classId)) return res.status(400).json({ message: "Invalid classId" });
        if (!startDate || !endDate) return res.status(400).json({ message: "startDate and endDate are required" });

        try {
            const start = new Date(startDate as string);
            const end = new Date(endDate as string);
            end.setHours(23, 59, 59, 999);

            if (isNaN(start.getTime()) || isNaN(end.getTime())) {
                return res.status(400).json({ message: "Invalid date format. Use YYYY-MM-DD." });
            }

            // Grouped query for CGPA (from study_in) and card counts (from grades in the date range)
            const rows: any[] = await AppDataSource.query(
                `SELECT 
                    s.id AS studentId,
                    u.name AS studentName,
                    si.cumulative_grade AS cgpa,
                    SUM(CASE WHEN g.card = '1' THEN 1 ELSE 0 END) AS perfectCount,
                    SUM(CASE WHEN g.card = '2' THEN 1 ELSE 0 END) AS veryGoodCount,
                    SUM(CASE WHEN g.card = '3' THEN 1 ELSE 0 END) AS goodCount
                 FROM study_in si
                 INNER JOIN student s ON s.id = si.studentId
                 INNER JOIN user u ON u.id = s.id
                 LEFT JOIN grades g ON g.student_id = s.id 
                    AND g.class_id = ?
                    AND g.date_time >= ? 
                    AND g.date_time <= ?
                 WHERE si.classId = ?
                 GROUP BY s.id, u.name, si.cumulative_grade
                 ORDER BY u.name`,
                [classId, start, end, classId]
            );

            return res.status(200).json({
                classId,
                startDate,
                endDate,
                students: rows.map(r => ({
                    studentId: r.studentId,
                    studentName: r.studentName,
                    cgpa: Number(r.cgpa),
                    cards: {
                        perfect: Number(r.perfectCount), // ممتاز
                        veryGood: Number(r.veryGoodCount), // جيد جداً
                        good: Number(r.goodCount) // جيد
                    }
                }))
            });
        } catch (error) {
            console.error('Error fetching grades stats:', error);
            return res.status(500).json({ message: 'Internal server error while retrieving grades stats.' });
        }
    }
}