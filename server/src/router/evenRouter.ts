import { Router } from "express";
import { authenticate } from "../middleware/middleware";
import {
  createEvent,
  updateEvent,
  deleteEvent,
  getEventDetails,
  getTeacherEvents,
  getStudentEvents,
  getStudentFeed
} from "../controllers/eventController";

const router = Router();
router.use(authenticate);

router.post("/create/:id", createEvent);
router.put("/update/:id", updateEvent);
router.delete("/delete/:id", deleteEvent);
router.get("/get_teacher_events/:id", getTeacherEvents);
router.get("/get_student_events", getStudentEvents);
router.get("/details/:id", getEventDetails);
router.get("/get_student_feed", getStudentFeed);

export default router;
