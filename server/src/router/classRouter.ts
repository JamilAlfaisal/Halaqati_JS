import { Router } from "express";
import { authenticate } from "../middleware/middleware";
import { createClass, updateClass, deleteClass, getTeacherClasses, getClassDetails, getStudentClasses} from "../controllers/classController";

const router = Router();
router.use(authenticate);

router.post("/create", createClass);
router.put("/update/:id", updateClass);
router.delete("/delete/:id", deleteClass);
router.get("/get_teacher_classes", getTeacherClasses);
router.get("/details/:id", getClassDetails);
router.get("/get_student_classes", getStudentClasses);

export default router;
