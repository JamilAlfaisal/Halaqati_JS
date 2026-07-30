import { Router } from "express";
import { authenticate } from "../middleware/middleware";
import { requireAdmin } from "../middleware/requireAdmin";
import {
    takeAttendance,
    updateAttendance,
    deleteAttendance,
    getClassAttendanceForTeacher,
    getAttendanceDetails,
    getAttendanceStatsByClass,
    getAttendanceCountByDateRange
} from "../controllers/attendanceController";

const router = Router();
router.use(authenticate);

router.post("/take/:id", takeAttendance);
router.put("/update/:id", updateAttendance);
router.delete("/delete/:id", deleteAttendance);
router.get("/get/:id", getClassAttendanceForTeacher);
router.get("/details/:id", getAttendanceDetails);
router.get("/stats/:classId", getAttendanceStatsByClass);
router.get("/admin/count/:classId", requireAdmin, getAttendanceCountByDateRange);

export default router;
