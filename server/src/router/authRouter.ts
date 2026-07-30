import { Router } from 'express';
import { singUp, login, verifyUsers, updateFcmToken, createAdmin, adminCreateAccount, updateUser, getUserById } from '../controllers/authController';
import { authenticate } from '../middleware/middleware';
import { requireAdmin } from '../middleware/requireAdmin';

const router = Router();

router.post('/signup/user', singUp);
router.post('/login/user', login);
router.get('/auth_me/user', authenticate, verifyUsers);
router.patch('/update-fcm-token', authenticate, updateFcmToken);
router.post('/create-admin', authenticate, requireAdmin, createAdmin);
router.post('/admin/create-account', authenticate, requireAdmin, adminCreateAccount);
router.put('/update/:id', authenticate, requireAdmin, updateUser);
router.get('/user/:id', authenticate, requireAdmin, getUserById);

export default router;