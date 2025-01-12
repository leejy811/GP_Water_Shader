using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    public Transform waterTransform;
    public Transform cameraTransform;
    public RenderDepth cameraDepth;

    public float moveSpeed = 10f;
    public float jumpSpeed = 10f;
    public float gravity = -10f;
    public float yVelocity = 10f;

    public float sesitivity = 500f;
    public float rotationX;
    public float rotationY;

    CharacterController characterController;
    FogController fogController;

    void Start()
    {
        characterController = gameObject.GetComponent<CharacterController>();
        fogController = gameObject.GetComponent<FogController>();
        Texture2D Tex;
    }

    void Update()
    {
        float h = Input.GetAxis("Horizontal");
        float v = Input.GetAxis("Vertical");

        Vector3 moveDir = new Vector3(h, 0, v);

        moveDir = cameraTransform.TransformDirection(moveDir);
        moveDir *= moveSpeed;

        if(characterController.isGrounded)
        {
            yVelocity = 0;
            if(Input.GetKeyDown(KeyCode.Space))
            {
                yVelocity = jumpSpeed;
            }
        }

        yVelocity += (gravity * Time.deltaTime);
        moveDir.y = yVelocity;
        characterController.Move(moveDir * Time.deltaTime);

        float mouseMoveX = Input.GetAxis("Mouse X");
        float mouseMoveY = Input.GetAxis("Mouse Y");

        rotationY += mouseMoveX * sesitivity * Time.deltaTime;
        rotationX += mouseMoveY * sesitivity * Time.deltaTime;

        if (rotationX > 90f)
        {
            rotationX = 90f;
        }

        if (rotationX < -90f)
        {
            rotationX = -90f;
        }

        transform.eulerAngles = new Vector3(-rotationX, rotationY, 0);

        cameraDepth.enabled = waterTransform.position.y > transform.position.y;
        fogController.isFogOnOff = waterTransform.position.y > transform.position.y;
    }
}
