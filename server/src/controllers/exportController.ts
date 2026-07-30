import { Response } from 'express';
import { AuthRequest } from '../middleware/middleware';
import { AppDataSource } from '../data-source';
import { Class } from '../model/Class';
import * as ExcelJS from 'exceljs';

export const exportClassStatsToExcel = async (req: AuthRequest, res: Response) => {
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

        const cls = await AppDataSource.getRepository(Class).findOneBy({ id: classId });
        if (!cls) return res.status(404).json({ message: "Class not found" });

        // Query combining both Attendance and Grades/CGPA
        const rows: any[] = await AppDataSource.query(
            `SELECT 
                s.id AS studentId,
                u.name AS studentName,
                si.cumulative_grade AS cgpa,
                (
                    SELECT COUNT(DISTINCT a.id)
                    FROM student_attendance sa
                    INNER JOIN attendance a ON a.id = sa.attendanceId
                    WHERE sa.studentId = s.id 
                      AND a.classId = ?
                      AND a.date >= ? 
                      AND a.date <= ?
                ) AS attendanceCount,
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
            [classId, start, end, classId, start, end, classId]
        );

        const workbook = new ExcelJS.Workbook();
        const worksheet = workbook.addWorksheet('إحصائيات الطلاب'); // Student Stats
        
        // Make the worksheet RTL for Arabic text
        worksheet.views = [{ rightToLeft: true }];

        worksheet.columns = [
            { header: 'اسم الطالب', key: 'studentName', width: 30 }, // Student Name
            { header: 'النسبة التراكمية', key: 'cgpa', width: 15 }, // CGPA
            { header: 'عدد أيام الحضور', key: 'attendanceCount', width: 20 }, // Attendance Count
            { header: 'بطاقات ممتاز', key: 'perfectCount', width: 15 }, // Perfect Cards (1)
            { header: 'بطاقات جيد جداً', key: 'veryGoodCount', width: 15 }, // Very Good Cards (2)
            { header: 'بطاقات جيد', key: 'goodCount', width: 15 } // Good Cards (3)
        ];

        // Add rows
        rows.forEach(row => {
            worksheet.addRow({
                studentName: row.studentName,
                cgpa: Number(row.cgpa),
                attendanceCount: Number(row.attendanceCount),
                perfectCount: Number(row.perfectCount),
                veryGoodCount: Number(row.veryGoodCount),
                goodCount: Number(row.goodCount)
            });
        });

        // Style header row
        worksheet.getRow(1).font = { bold: true };
        worksheet.getRow(1).alignment = { horizontal: 'center' };

        const exportDate = new Date().toISOString().split('T')[0];
        // Clean class name to avoid invalid filename characters
        const cleanClassName = (cls.name || 'Class').replace(/[/\\?%*:|"<>]/g, '-');
        const fileName = `${cleanClassName}_${exportDate}.xlsx`;

        // Setting up response headers for file download
        res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        res.setHeader('Content-Disposition', `attachment; filename="${encodeURIComponent(fileName)}"`);

        // Stream workbook to response
        await workbook.xlsx.write(res);
        res.status(200).end();

    } catch (error) {
        console.error('Error exporting class stats:', error);
        if (!res.headersSent) {
            return res.status(500).json({ message: 'Internal server error while exporting stats.' });
        }
    }
};
