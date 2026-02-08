import { Router } from "express";
import { authenticate } from "../middleware/middleware";
import { addStudentToClass, removeStudentFromClass, getClassStudents} from "../controllers/studentClassController";

const router = Router();
router.use(authenticate);

router.post("/add/:id", addStudentToClass);
router.delete("/remove/:id", removeStudentFromClass);
router.get("/get/:id", getClassStudents);


export default router;
