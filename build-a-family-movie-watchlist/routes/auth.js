import { Router } from "express";
import jwt from "jsonwebtoken";
import bcrypt from "bcryptjs";
import { findByUsername } from "../utils/db.js";

const router = Router();
const SECRET_KEY = process.env.JWT_SECRET || "supersecret";

router.post("/login", async (req, res) => {
  const { username, password } = req.body;

  // 1. Validar presencia de campos
  if (!username || !password) {
    return res.status(400).json({ error: "Username and password required." });
  }

  // 2. Buscar usuario
  const user = findByUsername(username);
  if (!user) {
    return res.status(401).json({ error: "Invalid credentials." });
  }

  // 3. Validar contraseña contra el hash
  const isMatch = await bcrypt.compare(password, user.passwordHash);
  if (!isMatch) {
    return res.status(401).json({ error: "Invalid credentials." });
  }

  // 4. Firmar Token
  const token = jwt.sign(
    { id: user.id, username: user.username, role: user.role },
    SECRET_KEY
  );

  return res.status(200).json({ token });
});

export default router;