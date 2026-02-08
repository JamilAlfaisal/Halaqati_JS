import { Router } from "express";
import { authenticate } from "../middleware/middleware";
import { 
    takeAttendance,
    updateAttendance,
    deleteAttendance,
    getClassAttendanceForTeacher,
    getAttendanceDetails
} from "../controllers/attendanceController";

const router = Router();
router.use(authenticate);

router.post("/take/:id", takeAttendance);
router.put("/update/:id", updateAttendance);
router.delete("/delete/:id", deleteAttendance);
router.get("/get/:id", getClassAttendanceForTeacher);
router.get("/details/:id", getAttendanceDetails);

export default router;
