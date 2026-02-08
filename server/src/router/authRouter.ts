import { Router } from 'express';
import { singUp, login, verifyUsers } from '../controllers/authController';
import { authenticate } from '../middleware/middleware';


const router = Router();

router.post('/signup/user', singUp);
router.post('/login/user', login);
router.get('/auth_me/user', authenticate, verifyUsers);

export default router;