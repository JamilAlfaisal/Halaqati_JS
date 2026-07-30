import { Router } from 'express';
import { PagesController } from '../controllers/pagesController';
import { authenticate } from '../middleware/middleware';
import { requireAdmin } from '../middleware/requireAdmin';

const router = Router();
router.use(authenticate);

const pagesController = new PagesController();

router.post('/memorize', pagesController.updateMemorizedPage);
router.post('/review', pagesController.updateReviewDate);
router.post('/unselect_memorized', pagesController.unselectMemorizedPage);
router.post('/pages_by_juz', pagesController.getPagesByJuz);
router.get('/admin/class/:classId/summary', requireAdmin, pagesController.getAdminClassPageProgressSummary);
router.get('/admin/student/:studentId/class/:classId/progress', requireAdmin, pagesController.getAdminStudentPageProgress);
router.get('/admin/students/directory', requireAdmin, pagesController.getAdminGlobalStudentDirectory);

export default router;