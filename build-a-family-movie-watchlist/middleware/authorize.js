export function authorizeModification(req, res, next) {
  const user = req.user;
  const targetUserId = req.params.userId;

  if (!user) {
    return res.status(403).json({ error: "Access denied" });
  }

  // Si es parent, tiene permiso total
  if (user.role === "parent") {
    return next();
  }

  // Si es child, solo si coincide su ID con el userId de los params
  if (user.role === "child" && String(user.id) === String(targetUserId)) {
    return next();
  }

  return res.status(403).json({ error: "Access denied" });
}