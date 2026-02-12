package hu.patrik.mozi.service;

import hu.patrik.mozi.model.User;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.List;
import java.util.Optional;
import org.mindrot.jbcrypt.BCrypt;

@Stateless
public class UserService {

    @PersistenceContext(unitName = "moziPU")
    private EntityManager em;

    public List<User> findAll() {
        return em.createQuery("SELECT u FROM User u", User.class)
                 .getResultList();
    }

    public User create(User user) {
        String hashed = BCrypt.hashpw(user.getPassword(), BCrypt.gensalt());
        user.setPassword(hashed);
        em.persist(user);
        return user;
    }

    public Optional<User> findByEmail(String email) {
        List<User> list = em.createQuery(
                "SELECT u FROM User u WHERE u.email = :email", User.class)
                .setParameter("email", email)
                .getResultList();

        return list.stream().findFirst();
    }

    public Optional<User> authenticate(String email, String rawPassword) {
        Optional<User> optionalUser = findByEmail(email);

        if (optionalUser.isPresent()) {
            User user = optionalUser.get();
            if (BCrypt.checkpw(rawPassword, user.getPassword())) {
                return Optional.of(user);
            }
        }

        return Optional.empty();
    }
}
