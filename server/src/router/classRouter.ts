import { Router } from "express";
import { authenticate } from "../middleware/middleware";
import { requireAdmin } from "../middleware/requireAdmin";
import { createClass, updateClass, deleteClass, getTeacherClasses, getClassDetails, getStudentClasses, getAllClasses, getAllTeachers } from "../controllers/classController";

import { exportClassStatsToExcel } from "../controllers/exportController";

const router = Router();
router.use(authenticate);

router.post("/create", createClass);
router.put("/update/:id", updateClass);
router.delete("/delete/:id", deleteClass);
router.get("/get_teacher_classes", getTeacherClasses);
router.get("/details/:id", getClassDetails);
router.get("/get_student_classes", getStudentClasses);
router.get("/all", requireAdmin, getAllClasses);
router.get("/teachers", requireAdmin, getAllTeachers);
router.get("/admin/export/:classId", requireAdmin, exportClassStatsToExcel);

export default router;
