import { Router } from "express";
import { authenticate } from "../middleware/middleware";
import { 
    createAssignment, 
    updateAssignment, 
    deleteAssignment,
    getAssignmentDetails,
    getTeacherAssignments,
    markAsCompleteUncomplete,
    getStudentsAssignment
  } from "../controllers/assignmentController";

const router = Router();
router.use(authenticate);

router.post("/create/:id", createAssignment);
router.put("/update/:id", updateAssignment);
router.delete("/delete/:id", deleteAssignment);
router.get("/get_teacher_assignment", getTeacherAssignments);
router.get("/details/:id", getAssignmentDetails);
router.put("/mark_as_complete_uncomplete/:id", markAsCompleteUncomplete);
router.get("/get_student_assignment", getStudentsAssignment);

export default router;
