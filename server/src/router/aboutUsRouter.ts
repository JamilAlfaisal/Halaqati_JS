import { Router } from "express";
import { getAboutUs } from "../controllers/aboutAsController";

const router = Router();

router.get("/", getAboutUs);

export default router;
