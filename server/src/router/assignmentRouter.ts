import { Router } from "express";
import { authenticate } from "../middleware/middleware";
import {
  createAssignment,
  updateAssignment,
  deleteAssignment,
  getAssignmentDetails,
  getTeacherAssignments,
  markAsCompleteUncomplete,
  getAssignmentDetailsOfStudent,
  getStudentsAssignment,
  getStudentAssignmentsByTeacher,
  markAssignmentAsRead,
  getStudentStats
} from "../controllers/assignmentController";

const router = Router();
router.use(authenticate);

router.post("/create/:id", createAssignment);
router.put("/update/:id", updateAssignment);
router.delete("/delete/:id", deleteAssignment);
router.get('/get_class_assignments/:classId', getTeacherAssignments);
router.get("/details/:id", getAssignmentDetails);
router.get("/details/:id/student/:id", getAssignmentDetailsOfStudent);
router.put("/mark_as_complete_uncomplete/:id", markAsCompleteUncomplete);
router.get("/get_student_assignment/:classId/:id", getStudentAssignmentsByTeacher);
router.get("/get_student_assignment", getStudentsAssignment);
router.put("/mark_as_read/:id", markAssignmentAsRead);
router.get("/student_state", getStudentStats);

export default router;
