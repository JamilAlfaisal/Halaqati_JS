import { Router } from "express";
import { authenticate } from "../middleware/middleware";
import { createClass, updateClass, deleteClass, getMyClasses, getClassDetails} from "../controllers/classController";

const router = Router();
router.use(authenticate);

router.post("/create", createClass);
router.put("/update/:id", updateClass);
router.delete("/delete/:id", deleteClass);
router.get("/get_my_classes", getMyClasses);
router.get("/details/:id", getClassDetails);

export default router;
