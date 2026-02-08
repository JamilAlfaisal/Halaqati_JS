import { Router } from 'express';
import { updateMemorizedJuz } from '../controllers/juzController';
import { authenticate } from '../middleware/middleware';


const router = Router();
router.use(authenticate);

router.put('/juz/:id', updateMemorizedJuz);

export default router;