import { Router } from 'express';
import { PagesController } from '../controllers/pagesController';
import { authenticate } from '../middleware/middleware';

const router = Router();
router.use(authenticate);

const pagesController = new PagesController();

router.post('/memorize', pagesController.updateMemorizedPage);
router.post('/review', pagesController.updateReviewDate);
router.post('/unselect_memorized', pagesController.unselectMemorizedPage);
router.post('/pages_by_juz', pagesController.getPagesByJuz);

export default router;