import { Router } from "express";
import { authenticate } from "../middleware/middleware";
import { 
    createEvent, 
    updateEvent, 
    deleteEvent,
    getEventDetails,
    getEvents
  } from "../controllers/eventController";

const router = Router();
router.use(authenticate);

router.post("/create", createEvent);
router.put("/update/:id", updateEvent);
router.delete("/delete/:id", deleteEvent);
router.get("/get", getEvents);
router.get("/details/:id", getEventDetails);

export default router;
