import { Router } from 'express';
import { GradesController } from '../controllers/gradesController';
import { authenticate } from '../middleware/middleware';
import { requireAdmin } from '../middleware/requireAdmin';

const router = Router();
router.use(authenticate);

const gradesController = new GradesController();

router.get('/get_grades/:studentId/class/:classId', gradesController.getStudentGrades);
router.post('/set_grade', gradesController.setGrade);
router.post('/update_grade', gradesController.updateGrade);
router.post('/delete_grade', gradesController.deleteGrade);
router.get('/admin/stats/:classId', requireAdmin, gradesController.getGradesStatsByDateRange);

export default router;